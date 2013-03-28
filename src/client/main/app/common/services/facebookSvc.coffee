###
Example of a service shared across views.
Wrapper around the data layer for the app. 
###
name = 'common.services.facebook'

angular.module(name, []).value(name, FB)
