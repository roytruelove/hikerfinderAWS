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

		initData = $q.all [
			$rootScope.me
			backend.getTrails()
		]

		initData.then (data)->
			[me, hikes] = data
			backend.getHikes(me.id).then (hikes)->
				$scope.hikes = for hike in hikes
					debugger
	])