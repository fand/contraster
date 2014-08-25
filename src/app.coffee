contrast = require './contrast.coffee'
util = require './util.coffee'
require 'angular/angular'

app = angular.module 'contrastApp', []
app.directive 'contrast', ->
    scope:
        h:  '='
        text: '@'
    replace: true
    templateUrl: '/public/contrast.html'
    link: (scope, element, attr) ->
        scope.s = 100
        scope.l = 50

        scope.$watch 's', -> update()
        scope.$watch 'l', -> update()

        update = () ->
            bg = util.getBg '.box'
            hsl_array = [+scope.h, +scope.s, +scope.l]
            rgb = contrast.readableDark bg, hsl_array, 3.0
            code = util.array2code rgb
            element.css 'color', code
