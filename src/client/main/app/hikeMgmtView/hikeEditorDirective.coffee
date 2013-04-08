name = 'hikeMgmtView.hikeEditorDirective'

# fbootstrap tabs js doesn't play nice with the facebook iframe, so
# had to write this
 
angular.module(name,[]).directive('hikeEditor', [
	'$log'
	($log)->

		link = (scope, element, attrs) ->

			scope.$watch 'hikeToEdit', (newVal)->
				if newVal?
					$(element).show(400)
				else $(element).hide(400)

		retVal =
			compile: (tElem, tAttr)->
				return link
	])