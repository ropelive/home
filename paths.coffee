module.exports = paths =
  scripts       :
    dir         : './app/src/'
    watch       : './app/src/*.coffee'
    source      : './app/src/index.coffee'
    destination : './dist/js/'
    filename    : './app.js'
  styles        :
    source      : './app/styl/app.styl'
    watch       : './app/styl/*.styl'
    destination : './dist/css/'
  entryPoint    :
    source      : './app/index.html'
    watch       : './app/index.html'
    destination : './dist/'
  images        :
    source      : './app/images/*'
    destination : './dist/images/'
  server        :
    dir         : './server'
    source      : './server/index.coffee'
