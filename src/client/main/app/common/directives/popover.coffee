name = 'common.directives.popover'

# fbootstrap tabs js doesn't play nice with the facebook iframe, so
# had to write this
 
angular.module(name,[]).directive('popover', [
	'$log'
	($log)->

		link = (scope, element, attrs) ->

			element.popover()

		retVal =
			compile: (tElem, tAttr)->
				return link
	])