contrast = require './contrast.coffee'
util = require './util.coffee'
require 'angular/angular'

app = angular.module 'contrastApp', []
app.directive 'contrast', ->
    scope:
        hue:  '='
        text: '@'
    replace: true
    templateUrl: '/templates/contrast.html'
    link: (scope, element, attr) ->
        box = element[0].querySelector '.box'

        update = () ->
            bg = util.getBg '.box'
            hsl_array = [+scope.h, +scope.s, +scope.l]
            rgb = contrast.darkOnLight bg, hsl_array, 3.0
            scope.rgb_code = util.array2code rgb
            scope.hsl_code = util.array2str 'hsl', util.rgb2hsl(rgb)
            scope.isValid = validate rgb

        validate = (array) ->
            for c in array
                return false if c < 0 or 255 < c
            return true

        scope.h = scope.hue
        scope.s = 100
        scope.l = 50
        update()

        scope.$watch 'h', -> update()
        scope.$watch 's', -> update()
        scope.$watch 'l', -> update()
