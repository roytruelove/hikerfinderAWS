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
		$scope.selectedYear = "#{moment().year()}"

		$scope.trails = backend.getTrails()
		$scope.selectedTrail = 1; #AT by default

		populateHikes = ()->
			$scope.myHikes = $rootScope.me.then (me)->
				backend.getHikesForUser(me.id).then (hikes)->

					hikes = for hike in hikes
						((h)->
							backend.getTrail(h.Trail).then (trailTitle)->
								h.Trail = trailTitle.name
						)(hike)

						hike

					return hikes
					
		populateHikes()

		$scope.saveHike = ()->
			$rootScope.me.then (me)->
				backend.addHike(me.id,$scope.selectedYear,$scope.selectedTrail,$scope.trailName,$scope.notes).then ()->
					$scope.hikeToEdit = null	
					debugger
					populateHikes()
				(error)->
					$log.log error
					alert ("Did not save new hike.  #{error}")

		$scope.addNewHike = ()->
			$scope.hikeToEdit = -1
	])