name = 'common.directives.tabs'

# fbootstrap tabs js doesn't play nice with the facebook iframe, so
# had to write this
 
angular.module(name,[]).directive('tab', [
	'$log'
	($log)->

		link = (scope, element, attrs) ->
			element.click ()->
				contentId = attrs['tab']
				contentElem = $("##{contentId}")
				contentElem.siblings().hide()
				contentElem.show()

				parentLi = element.parent('li')
				parentLi.addClass('active')
				parentLi.siblings().removeClass('active')

		retVal =
			compile: (tElem, tAttr)->
				return link
	])