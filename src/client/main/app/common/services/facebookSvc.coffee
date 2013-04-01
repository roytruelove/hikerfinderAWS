###
Example of a service shared across views.
Wrapper around the data layer for the app. 
###
name = 'common.services.facebook'

class FacebookSvc

	constructor: (@$log, @$q, @$rootScope) ->

		@initDefer = @$q.defer()

		# used to ensure that all facebook calls are done after initialization	
		@initialized = @initDefer.promise

	api: () ->
		FB

	# see https://developers.facebook.com/docs/howtos/login/getting-started/#step2
	init: ()->

		login = ()=>
			FB.login (resp)=>

				@$rootScope.$apply ()=>

					if resp.status == "not_authorized"
						@initDefer.reject()

					else
						@initDefer.resolve(resp.authResponse)

		window.fbAsyncInit = ()=>

			FB.init
				appId: 139217892923792
				channelUrl: '//localhost:5000/channel.html'
				status: true
				cookie: true
				xfbml: true

			FB.getLoginStatus (resp)=>
				if resp.status == 'connected'
					@$rootScope.$apply ()=>
						@initDefer.resolve(resp.authResponse)
				else if resp.status == 'not_authorized'
					login()
				else
					login()

		loadFbAsync = (d)=>
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

		return @initialized

	run: (url)->

		@initialized.then ()=>

			d = @$q.defer()

			@api().api "/#{url}", (resp)=>
				@$rootScope.$apply ()=>
					d.resolve(resp)

			return d.promise

angular.module(name, []).factory(name, [
	'$log',
	'$q',
	'$rootScope',
	($log, $q, $rootScope) ->
		new FacebookSvc($log, $q, $rootScope)
])
