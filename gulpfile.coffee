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

# gulp.task "vendor", ->
#     browserify()
#         .pipe plumber()
#         .transform(debowerify)
#         .require "./bower_components/**/*.js"
#         .pipe source("vendor.js")
#         .pipe gulp.dest("./public")

gulp.task 'css', ->
    gulp
        .src './app/styles/*.scss'
        .pipe plumber()
        .pipe sass()
        .pipe gulp.dest './public'

gulp.task 'watch', ['build'], ->
    gulp.watch 'app/**/*.coffee', ['js']
    gulp.watch 'app/**/*.jade', ['js']
    gulp.watch 'app/styles/**/*.scss', ['css']
    # gulp.watch 'bower_components/**/*.js', ['vendor']

#gulp.task 'build', ['vendor', 'js', 'css']
gulp.task 'build', ['js', 'css']
gulp.task 'default', ['build']
