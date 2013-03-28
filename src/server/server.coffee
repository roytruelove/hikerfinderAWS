express = require('express')

port = 5000
adminPort = 8111

createAppServer = ()->
	app = express();

	app.configure ()->
		app.use(express.static(__dirname + '/public'))
		app.use(express.bodyParser())

	app.post '/', (req, resp)->
		console.log req.body
		resp.send("Hello World")

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