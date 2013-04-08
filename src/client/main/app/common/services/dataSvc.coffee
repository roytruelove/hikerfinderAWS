###
Example of a service shared across views.
Wrapper around the data layer for the app. 
###
name = 'common.services.dataSvc'

class DataSvc

	constructor: (@$log, @$q, @$http) ->

		@hardcoded = {}

		@hardcoded.myTrails = 
		[
			{
				"Trail":"1",
				"TrailName":"Kilgore Trout",
				"AddedDate":"1230629602",
				"Year":"2007",
				"TrailYear":"1_2007",
				"Notes":"July 20somethin' @ Bennington, VT ->Sept 30 @ Katahdin",
				"FBID":"672579111"
			},
			{
				"TrailYear":"3_2008",
				"Year":"2008",
				"Trail":"3",
				"FBID":"672579111",
				"Notes":"Started September 21st from St. John Pied-de-Port, made it to Santiago on October 27.",
				"AddedDate":"1230575454"
			},
			{
				"Trail":"1",
				"TrailName":"Kilgore Trout",
				"AddedDate":"1230629530",
				"Year":"2006",
				"TrailYear":"1_2006",
				"Notes":"March 17 @ Springer ->Aug 5 @ Bennington, VT",
				"FBID":"672579111"
			}
		]

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

		# maps trail id to it's object for easier looking
		@hardcoded.trailsMap = (()=>
			map = {}

			for trail in @hardcoded.trails
				map[trail.id] = trail

			map
		)()

	getTrails: ()->
		@$q.when @hardcoded.trails

	getHikes: (trailId, year, nameFilter)->
		return @_getItems("/getHikes/#{trailId}/#{year}")

	getHikesForUser: (FBID)->
		return @_getItems("/getHikesForUser/#{FBID}")

	getTrail: (trailId)->
		@$q.when @hardcoded.trailsMap[trailId]

	addHike: (FBID, Year, TrailId, TrailName, Notes)->

		AddedDate = moment().unix()
		TrailYear = "#{Year}_#{TrailId}"

		queryStr = "Trail=#{window.escape(TrailId)}"
		queryStr += "&TrailName=#{window.escape(TrailName)}" if TrailName
		queryStr += "&AddedDate=#{window.escape(AddedDate)}"
		queryStr += "&Year=#{window.escape(Year)}"
		queryStr += "&TrailYear=#{window.escape(TrailYear)}"
		queryStr += "&Notes=#{window.escape(Notes)}" if Notes
		queryStr += "&FBID=#{window.escape(FBID)}"

		return @_get("/addHike?#{queryStr}")

	yearsList: ()->

		years = []

		currentYear = moment().year() + 2 # +2 for planned hikes
		startYear = 1960

		for yearVal in [currentYear..startYear]
			years.push {id:yearVal, year:yearVal}

		return years

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
		'$q'
		'$http'
		($log, $q, $http) ->
			new DataSvc($log, $q, $http)
	]
)
