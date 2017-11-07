module.exports = constants =
  HOST           : 'https://secure2.rope.live'
  NAME           : 'rope-home'
  AUTH           : false

  LOG_LEVEL      : 0

  AUTO_CONNECT   : false
  AUTO_RECONNECT : true

  BROWSERIFY_CDN : 'https://npm.rope.live'
  BABEL_OPTIONS  :
    presets: [
      'es2015'
      'react'
      'stage-0'
    ]
    plugins: [
      'transform-class-properties'
      'transform-object-assign'
      'transform-runtime'
    ]
