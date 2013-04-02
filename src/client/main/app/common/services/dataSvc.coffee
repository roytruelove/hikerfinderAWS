###
Example of a service shared across views.
Wrapper around the data layer for the app. 
###
name = 'common.services.dataSvc'

class DataSvc

	constructor: (@$log, @$timeout, @env) ->

		@hardcoded = {}

		@hardcoded.trails = 
			'1':
				name: 'Appalachian Trail'
			'2':
				name: 'Continental Divide Trail'
			'3':
				name: 'Pacific Crest Trail'

		@hardcoded.hikes =
			'1_2006':
				'672579111': 
					trail: 1
					trailName: 'Kilgore Trout'
					year: 2006
					notes: 'GA->VT'
					fbid: '672579111'
				'106232': 
					trail: 1
					trailName: 'Jules'
					year: 2006
					notes: 'GA->ME'
					fbid: '106232'
			'1_2007':
				'672579111': 
					trail: 1
					trailName: 'Kilgore Trout'
					year: 2007
					notes: 'VT->ME'
					fbid: '672579111'

	getTrails: ()->
		@$timeout ()=>
			return @hardcoded.trails

	getUserHikes: (fbId)->
		@$timeout ()=>

			userHikes = []
			$.each hikes, (trailYear)->

			return @hardcoded.hikes[fbId]

angular.module(name, []).factory(name, ['$log','$timeout', 'common.services.env', ($log, $timeout, env) ->
	new DataSvc($log, $timeout, env)
])