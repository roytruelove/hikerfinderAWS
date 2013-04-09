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

		# don't edit anything yet.  Editor directive watches var
		$scope.hikeToEdit = null
		$scope.years = backend.yearsList()

		$scope.trails = backend.getTrails()

		resetFormData = ()->
			if $scope.hikeToEdit == null || $scope.hikeToEdit == -1
				$scope.selectedYear = "#{moment().year()}"
				$scope.selectedTrail = 1; #AT by default
				$scope.trailName = ''
				$scope.notes = ''
			else 
				# find the hike and populate it
				$scope.myHikes.then (hikes)->
					editHike = (h for h in hikes when h.TrailYear == $scope.hikeToEdit)
					editHike = editHike[0]
					debugger	
					$scope.selectedYear = editHike.Year
					$scope.selectedTrail = editHike.TrailId
					$scope.trailName = editHike.TrailName
					$scope.notes = editHike.Notes

		populateHikes = ()->

			hikeSorter = (hike1, hike2)->
				if (hike1.Tear != hike2.Tear)
					if hike1.Trail < hike2.Trail
						return -1
					return 1
				else
					if hike1.Year < hike2.Year
						return -1
					return 1

			$scope.myHikes = $rootScope.me.then (me)->
				backend.getHikesForUser(me.id).then (hikes)->

					hikes = for hike in hikes
						((h)->
							backend.getTrail(h.Trail).then (trailTitle)->
								$log.log h
								h.TrailId = parseInt(h.Trail)
								h.Trail = trailTitle.name
						)(hike)

						hike

					hikes = hikes.sort (hikeSorter)
					return hikes

		resetFormData()
		populateHikes()

		$scope.saveHike = ()->
			$rootScope.me.then (me)->
				backend.addHike(me.id,$scope.selectedYear,$scope.selectedTrail,$scope.trailName,$scope.notes).then ()->
					$scope.hikeToEdit = null	
					populateHikes()
					$rootScope.$broadcast("hikeAdded")
				(error)->
					$log.log error
					alert ("Did not save new hike.  #{error}")

		$scope.addNewHike = ()->
			$scope.hikeToEdit = -1 #-1 is a new hike

		$scope.editHike = (hikeId)->
			$scope.hikeToEdit = hikeId
			resetFormData()

		$scope.cancelSaveHike = ()->
			$scope.hikeToEdit = null
			resetFormData()
	])