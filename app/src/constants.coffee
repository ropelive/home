module.exports = ->

  defaults =
    NODE_NAME      : 'rope-home'
    ROPE_DEBUG     : 0
    ROPE_SERVER    : 'https://secure2.rope.live'
    AUTO_CONNECT   : true
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

  ls = (key) -> try localStorage[key]

  current = {}

  for own key, val of defaults
    current[key] = process.env[key] ? ls(key) ? val

  return current
