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

		# NOTE! This will not work for friends over #500.  Fix that!
		friends = fb.run('me/friends').then (friends)->
			return friends.data

		$scope.trails = backend.getTrails()
		$scope.years = (()->

			years = []

			currentYear = moment().year() + 2 # +2 for planned hikes
			startYear = 1960

			for yearVal in [currentYear..startYear]
				years.push {id:yearVal, year:yearVal}

			return years
		)()

		#$scope.selectedYear = "#{moment().year()}"
		$scope.selectedYear = "2006"
		$scope.selectedTrail = "1"

		# Utility function.  Should be moved to a service
		stringContains =  (str, term, cs) ->
			if (cs? and cs)
				str.indexOf(term) != -1
			else if (!str?) || (!term?)
				return false
			else 
				str.toUpperCase().indexOf(term.toUpperCase()) != -1

		refreshHikes = ()->

			$scope.nameFilter = ''

			backend.getHikes($scope.selectedTrail, $scope.selectedYear).then (hikes)->

				hikes = hikes.sort (a,b)->
					return b.AddedDate - a.AddedDate

				hikes = for hike in hikes

					fbid = hike.FBID

					hike.FullName = fb.run("#{fbid}?fields=name").then (user)->
						return user.name
					, (error)->
						return '(No longer on Facebook)'

					# have to wrap this in a function to avoid funky scope issues with the
					# facebook ID inside the promise
					populateIsFriend = ((facebookId)->
						hike.isFriend = friends.then (friends)->

							$log.log "Running for fbid #{facebookId}"

							matchedFriends = (friend for friend in friends when friend.id == facebookId)

							return matchedFriends.length > 0
					)(fbid)

					hike.AddedDate = moment.unix(hike.AddedDate).fromNow()

					hike

				$scope.allHikes = hikes
				$scope.hikes = hikes

		applyNameFilter = (nameFilter)->

			unless nameFilter? && nameFilter.length != 0
				$scope.hikes = $scope.allHikes
				return

			shouldBeDisplayed = (hike, filter)->

				$q.when(hike.FullName).then (fullName)->
					return $q.when(hike.TrailName).then (trailName)->
						stringContains(fullName, filter) || stringContains(trailName, filter)

			filteredHikes = []

			for hike in $scope.allHikes

				fn  =((h)-> 
					shouldBeDisplayed(h, nameFilter).then (shouldDisplay)->
						if shouldDisplay
							filteredHikes.push h
				) hike

			$scope.hikes = filteredHikes
			console.log [filteredHikes]

		$scope.$watch 'selectedYear', ()->
			refreshHikes()

		$scope.$watch 'selectedTrail', ()->
			refreshHikes()

		$scope.$watch 'nameFilter', ()->
			applyNameFilter $scope.nameFilter

		$scope.getTrail = (id)->
			return backend.getTrail(id).name
	])