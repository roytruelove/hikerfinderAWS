name = 'hikeMgmtView.hikeMgmtViewCtrl'

angular.module(name, []).controller(name, [
	'$log',
	'$scope',
	'$q',
	'$rootScope',
	'common.services.env'
	'common.services.facebook'
	'common.services.dataSvc'
	($log, $scope, $q, $rootScope, envSvc, fb, backend) ->

		# don't edit anything yet.  Editor directive watches var
		$scope.hikeToEdit = null
		$scope.years = backend.yearsList()

		$scope.trails = backend.getTrails()

		$scope.myHikes = $rootScope.me.then (me)->
			backend.getHikesForUser(me.id).then (hikes)->

				hikes = for hike in hikes
					((h)->
						backend.getTrail(h.Trail).then (trailTitle)->
							h.Trail = trailTitle.name
					)(hike)

					hike

				return hikes

		$scope.addNewHike = ()->
			$scope.hikeToEdit = -1 #-1 is a new hike

	])