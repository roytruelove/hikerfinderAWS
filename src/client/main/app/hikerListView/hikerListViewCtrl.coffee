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

		fb.run('me/friends').then (resp)->
			$scope.hikers = resp.data[0..100]

		$scope.isFriend = ()->
			if Math.random() > .5 then true else false

		###
		backend.getTrails().then (trails)->
			debugger
		###
	])