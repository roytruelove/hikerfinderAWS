express = require('express')
AWS = require('aws-sdk')

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
	###
	t.push {TableName:'Hikes',Item:{FBID: {S: '1630778359'},TrailYear: {S: '1_1972'},TrailName: {S: 'TJ aka Teej'},Notes: {S: 'Gorham to Monson'}}}
	###
	return t

createAppServer = ()->
	app = express();

	app.get '/dynamoDB/adder', (req, resp, next)->

		resp.contentType 'application/json'
		responses = []

		data = getAllHikeData()

		count = 0

		for hike in data
			count++
			console.log "Adding:"
			console.log hike
			ddb.putItem hike, (ddbErr, ddbResp)->

				if ddbErr?
					resp.send(500, JSON.stringify(ddbErr))

				unless ddbResp?
					resp.send(500, "Both were null")

				count--
				console.log "Count = #{count}}"

	app.get '/dynamoDB/:action', (req, resp, next)->

		resp.contentType 'application/json'

		action = req.params.action

		ddb[action] req.query, (ddbErr, ddbResp)->

			if ddbErr?
				resp.send(500, JSON.stringify(ddbErr))

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