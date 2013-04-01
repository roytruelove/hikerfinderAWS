name = 'index.indexCtrl'

angular.module(name, []).controller(name, [
	'$log',
	'$scope',
	'$q',
	'$rootScope',
	'common.services.env'
	'common.services.facebook'
	($log, $scope, $q, $rootScope, envSvc, fb) ->

		$rootScope.loggedIn = false

		$scope.isFriend = ()->
			if Math.random() > .5 then true else false

		fbLoginFailure = ()->
			# shows failure message
			$scope.unauthorized = true

		fbLoginSuccess = (authResp)->

			$rootScope.loggedIn = true
			$scope.unauthorized = false

			fb.run('me/friends').then (resp)->
				$scope.hikers = resp.data[0..100]

		fb.init().then(fbLoginSuccess, fbLoginFailure)
	])