name = 'searchView.searchViewCtrl'

angular.module(name, []).controller(name, [
	'$scope'
	'$log'
	'$location'
	'common.services.dataSvc'
	'common.services.toastrWrapperSvc'
	($scope, $log, $location, data, tstr) ->
	])