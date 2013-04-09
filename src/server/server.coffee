express = require('express')
AWS = require('aws-sdk')
q = require('q')
LRU = require('lru-cache')
_ = require('underscore')

# CONSTANTS
PORT = 5000
ADMIN_PORT = 8111

# 'GLOBALS'
ddb = null
cache = null

initAws = ()->

	awsConfig = 
		accessKeyId: process.env.AWS_ACCESS_KEY
		secretAccessKey: process.env.AWS_SECRET_KEY
		region: 'us-east-1'

	AWS.config.update awsConfig
	ddb = new AWS.DynamoDB.Client()

initCache = ()->

	options =
		max: 500
		dispose: (key, value)->
			console.log "Cache disposing of #{key}"
		maxAge: 1000 * 60 * 60 * 1 # 1 hour
		#maxAge: 1 #effectively disables cache

	cache = LRU(options)

callDynamoDb = (action, params)->

	deffered = q.defer()
	ddb[action] params, (ddbErr, ddbResp)->
		#console.log ['Called Dynamo', ddbErr, ddbResp]

		if ddbErr?
			console.log (['DDB Reject', ddbErr])
			deffered.reject(ddbErr)
			return

		unless ddbResp?
			console.log (['DDB Reject', "both null"])
			deffered.reject("Didn't get an error or a response")
			return

		console.log (['DDB Accept'])
		deffered.resolve (ddbResp)

	return deffered.promise

onSuccess = (resp)->
	return (data)->
		console.log (['Resp with success'])
		resp.send(JSON.stringify(data))

onFailure = (resp)->
	return (data)->
		console.log (['Resp with fail'])
		resp.send(500, JSON.stringify(data))

# Strips out all the metadata from the response and just returns the Items
cleanupDynamoDbItems = (resp)->

	cleanedItems = []

	for item in resp.Items

		cleanedItem = {}

		# iterate over each prop in the item
		_.each item, (itemObj, prop) ->

			# each item is an object with only one prop
			value = null

			_.each itemObj, (val) ->
				# should be only one, so we can take the first
				value = val

			cleanedItem[prop] = value
		cleanedItems.push cleanedItem

	resp.Items = cleanedItems
	return resp

handleCaching = (key, populateCacheFn)->

	value = cache.get(key)

	unless value?
		value = q.when(populateCacheFn()).then (data)->
			console.log "Added #{key} to the cache"
			cache.set(key, data)
			return data
	else
		value = q.when(value)
		console.log "Returned #{key} from the cache"

	return value

createAppServer = ()->
	app = express();

	# putItem example URL
	# http://localhost:5000/dynamoDB/putItem?TableName=Hikes&ItemJSON={%22FBID%22:{%22S%22:%221630778359%22},%22TrailYear%22:{%22S%22:%221_1972%22},%22TrailName%22:{%22S%22:%22TJ%20aka%20Teej%22},%22Notes%22:{%22S%22:%22Gorham%20to%20Monson%22}}
	app.get '/dynamoDB/:action/:params', (req, resp, next)->

		action = req.params.action
		params = JSON.parse(req.params.params)

		callDynamoDb(action, params).then onSuccess(resp), onFailure(resp)

	app.get '/getHikes/:trail/:year', (req, resp)->

		primaryKey = "#{req.params.trail}_#{req.params.year}"
		cacheKey = "getHikes_#{primaryKey}"

		handleCaching cacheKey, ()->
			params = 
				TableName: 'Hikes'
				HashKeyValue:
					S: primaryKey 

			callDynamoDb('query', params).then (data)->
				data = cleanupDynamoDbItems(data)
				return data

		.then onSuccess(resp), onFailure(resp)

	app.get '/addHike', (req, resp)->

		typeMap =
			TrailName: 'S'
			AddedDate: 'N'
			Year: 'N'
			Trail: 'N'
			TrailYear: 'S'
			Notes: 'S'
			FBID: 'S'

		errors = []

		itemObj =
			TableName: 'Hikes'
			Item: {}

		_.each typeMap, (type, varName) ->

			if req.query[varName]?
				itemObj.Item[varName] = {}
				itemObj.Item[varName][type] = req.query[varName]
				console.log ['Added Item', itemObj.Item[varName]]

		# console.log req.query
		# console.log itemObj
		# console.log errors

		if errors.length > 0
			q.reject(errors).then null, onFailure(resp)
		else
			callDynamoDb('putItem', itemObj).then(()->
				fbid = req.query.FBID
				cache.del("getHikesForUser_#{fbid}")
				key = "getHikes_#{req.query.Trail}_#{req.query.Year}"
				cache.del key
			).then onSuccess(resp), onFailure(resp)

	app.get '/getHikesForUser/:fbid', (req, resp)->

		fbid = req.params.fbid
		cacheKey = "getHikesForUser_#{fbid}"

		handleCaching cacheKey, ()->
			params = 
				TableName: 'Hikes'
				ScanFilter:
					FBID:
						AttributeValueList:
							[{S: fbid}]	
						ComparisonOperator: 'EQ'

			callDynamoDb('scan', params).then (data)->
				data = cleanupDynamoDbItems(data)
				return data

		.then onSuccess(resp), onFailure(resp)

	app.use(express.bodyParser())

	app.post '/', (req, resp, next)->
		req.method="GET"
		next()

	app.use(express.static(__dirname + '/public'))

	app.listen PORT, ()->
		console.log "Started Server on #{PORT}"

createAdminServer = ()->
	adminApp = express();

	adminApp.get '/', ()->
		process.exit()

	adminApp.listen ADMIN_PORT, ()->
		console.log "Started admin server on #{ADMIN_PORT}"

initAws()
initCache()
createAppServer()
createAdminServer()