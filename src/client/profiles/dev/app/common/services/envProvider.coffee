###
DEV
###
providerName = 'common.services.env' # angular adds the 'Provider' suffix for us.
modName = "#{providerName}Provider"

class Environment

	env: 'DEV'
	serverUrl: '' # blank because all $http calls will be faked

	constructor: (@$log)->

	appRun: ()->
		@$log.log ("Running custom 'run'-time initialization of the main app module")

class EnvironmentProvider

	$get: 
		[
			'$log'
			($log)->
				new Environment($log)
		]

	appConfig: ()->
		# using console because there's no 'log' object yet
		console.log("Running custom 'config'-time initialization of the main app module")

# note that we have to include the module names of our dependencies here since the main app
# modules won't know about them
mod = angular.module(modName, [])
mod.provider(providerName, new EnvironmentProvider())
