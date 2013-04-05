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

		$scope.myHikes = $rootScope.me.then (me)->
			backend.getHikesForUser(me.id).then (hikes)->

				hikes = for hike in hikes
					((h)->
						backend.getTrail(h.Trail).then (trailTitle)->
							h.Trail = trailTitle.name
					)(hike)

					hike

				return hikes

		$scope.myHikes.then (hikes)->
			console.log hikes
	])