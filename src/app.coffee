contrast = require './contrast.coffee'
util = require './util.coffee'
require 'angular/angular'

app = angular.module 'contrastApp', []
app.directive 'contrast', ->
    scope:
        h:  '='
        text: '@'
    replace: true
    templateUrl: '/templates/contrast.html'
    link: (scope, element, attr) ->
        box = element[0].querySelector '.box'

        update = () ->
            bg = util.getBg '.box'
            hsl_array = [+scope.h, +scope.s, +scope.l]
            rgb = contrast.readableDark bg, hsl_array, 3.0
            code = util.array2code rgb
            scope.isValid = validate rgb
            angular.element(box).css 'color', code

        validate = (array) ->
            for c in array
                return false if c < 0 or 255 < c
            return true


        scope.s = 100
        scope.l = 50

        scope.$watch 's', -> update()
        scope.$watch 'l', -> update()

        update()
