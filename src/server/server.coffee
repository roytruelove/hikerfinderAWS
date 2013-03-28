express = require('express')

app = express();

app.configure ()->
	app.use(express.static(__dirname + '/public'))

app.post '/', (req, resp)->
	debugger
	resp.send("Hello World")

app.listen 5000, ()->
	console.log "Started"