express = require('express')
AWS = require('aws-sdk')
_ = require('underscore')

awsConfig = 
	accessKeyId: process.env.AWS_ACCESS_KEY
	secretAccessKey: process.env.AWS_SECRET_KEY
	region: 'us-east-1'

AWS.config.update awsConfig

console.log awsConfig

port = 5000
adminPort = 8111

ddb = new AWS.DynamoDB.Client()

getAllHikeData = ()->
	t=[]
	t.push {TableName:'Hikes',Item:{FBID: {S: '1630778359'},TrailYear: {S: '1_1972'},TrailName: {S: 'TJ aka Teej'},Notes: {S: 'Gorham to Monson'}}}
	return t

createAppServer = ()->
	app = express();

	# putItem example URL
	# http://localhost:5000/dynamoDB/putItem?TableName=Hikes&ItemJSON={%22FBID%22:{%22S%22:%221630778359%22},%22TrailYear%22:{%22S%22:%221_1972%22},%22TrailName%22:{%22S%22:%22TJ%20aka%20Teej%22},%22Notes%22:{%22S%22:%22Gorham%20to%20Monson%22}}
	app.get '/dynamoDB/:action', (req, resp, next)->

		console.log JSON.stringify(getAllHikeData())

		resp.contentType 'application/json'

		action = req.params.action
		params = {}

		_.each req.query, (param, index)->

			#If the param ends in JSON, strip it off
			if index.indexOf('JSON', index.length - 4) != -1
				parsedVal = JSON.parse(param)
				index = index.substr(0,index.length - 4)
				params[index] = parsedVal
			else
				params[index] = param

		ddb[action] params, (ddbErr, ddbResp)->

			if ddbErr?
				resp.send(500, JSON.stringify(ddbErr))

			unless ddbResp?
				resp.send(500, "Didn't get an error or a response!")

			resp.send(JSON.stringify(ddbResp))

	app.use(express.bodyParser())

	app.post '/', (req, resp, next)->
		req.method="GET"
		next()

	app.use(express.static(__dirname + '/public'))

	app.listen port, ()->
		console.log "Started Server on #{port}"

createAdminServer = ()->
	adminApp = express();

	adminApp.get '/', ()->
		process.exit()

	adminApp.listen adminPort, ()->
		console.log "Started admin server on #{adminPort}"

createAppServer()
createAdminServer()