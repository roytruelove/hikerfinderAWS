###
Example of a service shared across views.
Wrapper around the data layer for the app. 
###
name = 'common.services.dataSvc'

class DataSvc

	constructor: (@$log, @$timeout, @$http) ->

		@hardcoded = {}

		@hardcoded.trails = [
			{id:'1', name: 'Appalachian Trail'}
			{id:'11', name: 'Colorado Trail'}
			{id:'3', name: 'Camino de Santiago (Camino Frances)'}
			{id:'7', name: 'Camino de Santiago (Camino Portugues)'}
			{id:'5', name: 'Camino de Santiago (Ruta del Norte)'}
			{id:'6', name: 'Camino de Santiago (Via de la Plata)'}
			{id:'4', name: 'Continental Divide Trail'}
			{id:'8', name: 'Long Trail'}
			{id:'10', name: 'John Muir Trail'}
			{id:'2', name: 'Pacific Crest Trail'}
			{id:'12', name: 'Other (Not Listed)'}
		]

	getTrails: ()->
		@$timeout ()=>
			return @hardcoded.trails

	getTrail:(id)->
		throw "Not done"
		return @hardcoded.trails[id]

	getHikes: (trailId, year, nameFilter)->
		return @_getItems("/getHikes/#{trailId}/#{year}")

	_get: (url)->
		@$http.get(url).then (resp)=>
			return resp.data
		, (errorResp)=>
			# TODO handle this elegantly
			@$log.log (['Could not handle request to server', errorResp])
			errorResp

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
