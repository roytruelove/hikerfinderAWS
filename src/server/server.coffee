express = require('express')

port = 5000
adminPort = 8111

createAppServer = ()->
	app = express();
	
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