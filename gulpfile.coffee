gulp       = require 'gulp'
rename     = require 'gulp-rename'
plumber    = require 'gulp-plumber'
concat     = require 'gulp-concat'
sass       = require 'gulp-ruby-sass'
bowerFiles = require "main-bower-files"
source     = require 'vinyl-source-stream'
browserify = require 'browserify'
debowerify = require 'debowerify'
webserver  = require 'gulp-webserver'

gulp.task 'js', ->
    browserify
        entries: ['./src/app.coffee']
        extensions: ['.coffee', '.js']
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe plumber()
    .pipe source 'app.js'
    .pipe gulp.dest 'docs'

gulp.task 'css', ->
    gulp
        .src './docs/css/*.scss'
        .pipe plumber()
        .pipe sass()
        .pipe gulp.dest './docs/css'

gulp.task 'server', ->
    gulp.src 'docs/'
        .pipe webserver
            open: true
            livereload: true
            port: 9999

gulp.task 'watch', ['build'], ->
    gulp.watch 'src/**/*.coffee', ['js']
    gulp.watch 'docs/**/*.scss', ['css']

gulp.task 'build', ['js', 'css']
gulp.task 'default', ['build', 'watch', 'server']
