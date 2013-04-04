name = 'hikerListView.hikerListViewCtrl'

angular.module(name, []).controller(name, [
	'$log',
	'$scope',
	'$q',
	'$rootScope',
	'common.services.env'
	'common.services.facebook'
	'common.services.dataSvc'
	($log, $scope, $q, $rootScope, envSvc, fb, backend) ->

		# XXX Temporary, this will come from user input later
		year = 2006
		trail = 1

		backend.getHikes(trail, year).then (data)->
			console.log data[0]
			$scope.hikers = data

		$scope.getTrail = (id)->
			return backend.getTrail(id).name
	])