###
Example of a service shared across views.
Wrapper around the data layer for the app. 
###
name = 'common.services.dataSvc'

class DataSvc

	constructor: (@$log, @$timeout, @$http) ->

		@hardcoded = {}

		@hardcoded.trails = 
			'1':
				name: 'Appalachian Trail'
			'2':
				name: 'Pacific Crest Trail'
			'3':
				name: 'Camino de Santiago (Camino Frances)'
			'4':
				name: 'Continental Divide Trail'
			'5':
				name: 'Camino de Santiago (Ruta del Norte)'
			'6':
				name: 'Camino de Santiago (Via de la Plata)'
			'7':
				name: 'Camino de Santiago (Camino Portugues)'
			'8':
				name: 'Long Trail'
			# No number 9
			'10':
				name: 'John Muir Trail'
			'11':
				name: 'Colorado Trail'
			'12':
				name: 'Other (Not Listed)'

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

	getHikes: (trailId, year, nameFilter)->

		url = "/getHikes/#{trailId}/#{year}"

		params = 
			TableName: 'Hikes'
			HashKeyValue:
				S: "#{trailId}_#{year}"

		return @_runDynamoQuery('query', params).then (resp)->
			return Items

	getUserHikes: (fbId)->
		return null

		url = "/dynamoDB/#{method}/#{JSON.stringify(params)}"
		console.log (["Backend call to #{url}", params])

		@$http.get(url).then (resp)=>
			return resp.data

angular.module(name, []).factory(
	name, [
		'$log'
		'$timeout'
		'$http'
		($log, $timeout, $http) ->
			new DataSvc($log, $timeout, $http)
	]
)
