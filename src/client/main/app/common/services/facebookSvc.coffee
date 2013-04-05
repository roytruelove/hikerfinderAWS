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
			@$log.log "Waiting for facebook to login..."
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

			@$log.log "Waiting for facebook login status..."
			FB.getLoginStatus (resp)=>
				if resp.status == 'connected'
					@$rootScope.$apply ()=>
						@initDefer.resolve(resp.authResponse)
				else 
					login()

		loadFbAsync = (d)=>
			@$log.log "loading facebook api..."
			id = 'facebook-jssdk'

			if (d.getElementById(id)?)
				@$log.log "facebook api loaded - element already exists"
				return

			ref = d.getElementsByTagName('script')[0]
			js = d.createElement('script')
			js.id = id
			js.async = true
			js.src = "//connect.facebook.net/en_US/all.js"
			ref.parentNode.insertBefore(js, ref)
			@$log.log "facebook api loaded"

		@$log.log "Waiting to load facebook api..."
		loadFbAsync(document)

		return @initialized

	run: (url)->

		@initialized.then ()=>

			d = @$q.defer()

			@api().api "/#{url}", (resp)=>
				@$rootScope.$apply ()=>

					if resp.error?
						#TODO handle this elegantly
						console.log ['Error in facebook API', resp.error]
						d.reject(resp.error)
					else
						d.resolve(resp)

			return d.promise

angular.module(name, []).factory(name, [
	'$log',
	'$q',
	'$rootScope',
	($log, $q, $rootScope) ->
		new FacebookSvc($log, $q, $rootScope)
])
