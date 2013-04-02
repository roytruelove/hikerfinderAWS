name = 'index.indexCtrl'

angular.module(name, []).controller(name, [
	'$log',
	'$scope',
	'$q',
	'$rootScope',
	'common.services.env'
	'common.services.facebook'
	($log, $scope, $q, $rootScope, envSvc, fb) ->

		meDef = $q.defer()
		$rootScope.me = meDef.promise #resolved when we get 'me' from facebook

		# shows big boot
		$rootScope.loggedIn = false

		fbLoginFailure = ()->
			# shows unauthorized message
			$scope.unauthorized = true

		fbLoginSuccess = (authResp)->

			# hide big boot
			$rootScope.loggedIn = true
			# hides unauthorized message
			$scope.unauthorized = false

			fb.run('me').then (resp)->
				meDef.resolve(resp)

		fb.init().then(fbLoginSuccess, fbLoginFailure)

	])