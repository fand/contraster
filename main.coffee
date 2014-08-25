contrast = require './contrast.coffee'
util = require './util.coffee'
require 'angular/angular'

hslCtrl = ($scope, $element) ->
    $scope.hsls = [
       { text: 'foo', h: 20,  s: 100, l: 50 },
       { text: 'bar', h: 140, s: 100, l: 50 },
       { text: 'baz', h: 260, s: 100, l: 50 }
    ]

    for i in [0...($scope.hsls.length)]
        $scope.$watch 'hsls['+i+']', ((val) -> update(val)), true

    update = (hsl) ->
        box = document.querySelector '.box'
        return unless box
        bg = getComputedStyle(box).backgroundColor
        return if bg.match /^\s*$/
        bg = util.str2array bg
        hsl_array = [+hsl.h, +hsl.s, +hsl.l]
        rgb = contrast.readableDark bg, hsl_array, 2.0
        code = util.array2code rgb
        console.log code
        $element.css 'color', code


app = angular.module 'hslApp', []
app.controller 'hslCtrl', ['$scope', '$element', hslCtrl]
app.directive 'hsl', ->
    link: hslLink
