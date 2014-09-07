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
        bg = util.getBg '.box'
        fix = 's'

        update = (option) ->
            hsl_array = [+scope.h, +scope.s, +scope.l]
            result = contrast.darkOnLight bg, hsl_array, scope.contrast, option.parameter

            if result?
                scope.is_valid = true
                scope.hsl_code = util.array2str 'hsl', result.hsl
                scope.rgb_code = util.array2code result.rgb
                scope.contrast_new = result.contrast
                scope.h = result.hsl[0]
                scope.s = result.hsl[1] * 100.0
                scope.l = result.hsl[2] * 100.0

            else
                scope.is_valid = false
                scope.hsl_code = '-'
                scope.rgb_code = '-'
                scope.contrast_new = '-'

        validate = (array) ->
            for c in array
                return false if c < 0 or 255 < c
            return true

        scope.contrast = 2.5
        scope.h = scope.hue
        scope.s = 100
        scope.l = 50
        update parameter: 'l'

        scope.$watch 'contrast', -> update parameter: 'l'
        scope.$watch 'h', -> update parameter: 'l'
        scope.$watch 's', -> update parameter: 'l'
        scope.$watch 'l', -> update parameter: 's'
