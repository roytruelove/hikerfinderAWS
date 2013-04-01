name = 'index.indexCtrl'

angular.module(name, []).controller(name, [
	'$log',
	'$scope',
	'$q',
	'$rootScope',
	'common.services.env'
	'common.services.facebook'
	($log, $scope, $q, $rootScope, envSvc, fb) ->

		#shows big boot
		$rootScope.loggedIn = false

		fbLoginFailure = ()->
			# shows failure message
			$scope.unauthorized = true

		fbLoginSuccess = (authResp)->

			# hide big boot
			$rootScope.loggedIn = true
			# hides failure message
			$scope.unauthorized = false

		fb.init().then(fbLoginSuccess, fbLoginFailure)

	])