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

	getTrails: ()->
		@$timeout ()=>
			return @hardcoded.trails

	getTrail:(id)->
		return @hardcoded.trails[id]

	getHikes: (trailId, year, nameFilter)->
		return @_getItems("/getHikes/#{trailId}/#{year}")

	_get: (url)->
		@$http.get(url).then (resp)=>
			return resp.data
		, (errorResp)=>
			# TODO handle this elegantly
			$log.log (['Could not handle request to server', errorResp])

	# Helper function when a request returns a list of items.
	_getItems: (url)->
		@_get(url).then (data)->
			return data.Items

angular.module(name, []).factory(
	name, [
		'$log'
		'$timeout'
		'$http'
		($log, $timeout, $http) ->
			new DataSvc($log, $timeout, $http)
	]
)
