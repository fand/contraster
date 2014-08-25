gulp       = require 'gulp'
rename     = require 'gulp-rename'
plumber    = require 'gulp-plumber'
concat     = require 'gulp-concat'
sass       = require 'gulp-ruby-sass'
bowerFiles = require "main-bower-files"
source     = require 'vinyl-source-stream'
browserify = require 'browserify'
debowerify = require 'debowerify'

gulp.task 'js', ->
    browserify
        entries: ['./src/app.coffee']
        extensions: ['.coffee', '.js']
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe plumber()
    .pipe source 'app.js'
    .pipe gulp.dest 'public'

gulp.task 'css', ->
    gulp
        .src './public/*.scss'
        .pipe plumber()
        .pipe sass()
        .pipe gulp.dest './public'

gulp.task 'watch', ['build'], ->
    gulp.watch 'src/**/*.coffee', ['js']
    gulp.watch 'styles/**/*.scss', ['css']

gulp.task 'build', ['js', 'css']
gulp.task 'default', ['build']
