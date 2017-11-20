require('dotenv').config()

gulp            = require 'gulp'
gutil           = require 'gulp-util'
stylus          = require 'gulp-stylus'
uglify          = require 'gulp-uglify'
streamify       = require 'gulp-streamify'
CSSmin          = require 'gulp-minify-css'

rimraf          = require 'rimraf'
source          = require 'vinyl-source-stream'
nodemon         = require 'nodemon'
watchify        = require 'watchify'
coffeeify       = require 'coffeeify'
browserify      = require 'browserify'
envify          = require 'envify/custom'

production      = process.env.NODE_ENV is 'production'

browserSync = require('browser-sync').create()
historyFallback = require('connect-history-api-fallback')

globalBundler   = null

paths = require './paths'

handleError = (err) ->
  err = err.message  if err.message?
  gutil.log err
  gutil.beep()
  this.emit 'end'


getBrowserifiedBundler = ->

  return globalBundler  if globalBundler

  globalBundler  = browserify
    cache        : {}
    packageCache : {}
    fullPaths    : {}
    entries      : [ paths.scripts.source ]
    extensions   : [ '.coffee' ]
    transform    : [ 'coffeeify', envify { API_URL: process.env.API_URL } ]
    debug        : !production



gulp.task 'compile-scripts', ->

  bundle = getBrowserifiedBundler().bundle()
    .on 'error', handleError
    .pipe source paths.scripts.filename

  bundle.pipe streamify uglify()  if production
  bundle
    .pipe gulp.dest paths.scripts.destination
    .pipe browserSync.reload { stream: yes }


gulp.task 'watch-server', (done) ->
  started = no

  return nodemon '-L --watch server server/index.coffee'
    .on 'start', ->
      return  if started
      started = yes
      done()


gulp.task 'client-server', ['compile-scripts'], ->
  browserSync.init
    notify: no
    port: 9001
    server:
      baseDir: './dist'
      middleware: [historyFallback()]


gulp.task 'watch', ->

  gulp.watch paths.styles.watch, [ 'styles' ]

  globalBundler = watchify getBrowserifiedBundler()
  globalBundler.on 'update', -> gulp.start 'compile-scripts'


gulp.task 'styles', ->

  styles = gulp
    .src paths.styles.source
    .pipe stylus set: ['include css']
    .on 'error', handleError

  styles = styles.pipe CSSmin()  if production

  styles
    .pipe gulp.dest paths.styles.destination


gulp.task 'images', ->

  gulp
    .src  paths.images.source
    .pipe gulp.dest paths.images.destination


gulp.task 'export-kd', ->

  # Just copy kd.css to dist
  gulp
    .src            './node_modules/kd.js/dist/kd.css'
    .pipe gulp.dest './dist/css/'


gulp.task 'clean', (cb) ->

  rimraf './dist', cb


gulp.task 'production', [ 'clean' ], ->

  production = yes

  gulp.start 'build', ->
    gutil.log 'Building for production is completed,
               you can now deploy ./dist folder'


gulp.task 'export-cm', ->

  # Just copy cm.css to dist
  gulp
    .src            [
      './node_modules/codemirror/lib/codemirror.css',
      './node_modules/codemirror/mode/javascript/javascript.js'
      './node_modules/codemirror/theme/tomorrow-night-eighties.css'
    ]
    .pipe gulp.dest './dist/cm/'


gulp.task 'entry-point', ->

  gulp
    .src  paths.entryPoint.source
    .pipe gulp.dest paths.entryPoint.destination



gulp.task 'build',   [
  'compile-scripts', 'styles', 'entry-point', 'export-kd', 'export-cm', 'images'
]

gulp.task 'default', [
  'build', 'watch', 'client-server'
 ]

