name = 'index.indexCtrl'

angular.module(name, []).controller(name, [
	'$log',
	'$scope',
	'$q',
	'$rootScope',
	'common.services.env'
	($log, $scope, $q, $rootScope, envSvc) ->

		runGraph = (url)->

			d = $q.defer()

			FB.api "/#{url}", (resp)->
				$scope.$apply ()->
					d.resolve(resp)

			return d.promise

		$scope.graphDumper = ()->

			input = $('#graphDumper').val()

			runGraph(input).then (resp)->
				$log.log resp

		$rootScope.loggedIn = false

		# see https://developers.facebook.com/docs/howtos/login/getting-started/#step2
		initFacebook = ()->

			fbDef = $q.defer()

			login = ()->
				FB.login (resp)->

					$scope.$apply ()->

						if resp.status == "not_authorized"
							$log.log 'Not Authorized'
							fbDef.reject()

						else
							$log.log 'Authorized'
							fbDef.resolve(resp.authResponse)

			window.fbAsyncInit = ()->

				FB.init
					appId: 139217892923792
					channelUrl: '//localhost:5000/channel.html'
					status: true
					cookie: true
					xfbml: true

				FB.getLoginStatus (resp)->
					if resp.status == 'connected'
						$log.log 'Connected'
						$scope.$apply ()->
							fbDef.resolve(resp.authResponse)
					else if resp.status == 'not_authorized'
						$log.log 'Not Authorized'
						login()
					else
						$log.log "Not Logged In"
						login()

			loadFbAsync = (d)->
				id = 'facebook-jssdk'

				if (d.getElementById(id)?)
					return

				ref = d.getElementsByTagName('script')[0]
				js = d.createElement('script')
				js.id = id
				js.async = true
				js.src = "//connect.facebook.net/en_US/all.js"
				ref.parentNode.insertBefore(js, ref)

			loadFbAsync(document)

			return fbDef.promise

		fbLoginFailure = ()->
			# shows failure message
			$scope.unauthorized = true

		fbLoginSuccess = (authResp)->

			$rootScope.loggedIn = true
			$scope.unauthorized = false

			runGraph('me/friends').then (resp)->
				$scope.hikers = resp.data[0..100]

		i = initFacebook()
		i.then(fbLoginSuccess, fbLoginFailure)
	])