kd = require 'kd.js'
{ Kite } = require 'kite.js'

{ ROPE_SERVER, ROPE_DEBUG, NODE_NAME
  AUTO_CONNECT, AUTO_RECONNECT, EVAL_TIMEOUT
  BABEL_OPTIONS, BROWSERIFY_CDN } = do require './constants'

uuid = require 'uuid'
Babel = require 'babel-standalone'
BrowserSandbox = require 'browser-module-sandbox'

module.exports = class Rope extends kd.Object

  constructor: (options = {}, data) ->

    super options, data

    @npmSandbox = new BrowserSandbox
      name: 'npm-sandbox',
      cdn: BROWSERIFY_CDN,
      container: document.getElementsByTagName('body')[0],
      # cacheOpts:
      #   inMemory: true
      iframeHead: ""
      iframeStyle: 'body, html { height: 100%; width: 100%; overflow: auto }'
      iframeSandbox: [
        'allow-forms', 'allow-popups', 'allow-scripts' #, 'allow-same-origin'
      ]

    @initializeKite()


  initializeKite: ->

    if @kite
      @kite?.disconnect()
      id = @kite.id
      kd.utils.defer => @kite.connect()

    # This package is not using @rope/node instead here we have some
    # custom implementation which provides same functionality with
    # @rope/node with some additions.
    # Please make sure this one to use @rope/node in the future
    # or keep them in sync ~ GG
    @kite = new Kite
      url           : ROPE_SERVER
      api           : @getApi()
      name          : NODE_NAME
      logLevel      : ROPE_DEBUG
      environment   : 'Browser'
      autoConnect   : AUTO_CONNECT
      autoReconnect : AUTO_RECONNECT
      transportClass: Kite.transport.SockJS

    @kite.id = id  if id or id = @getOption 'kiteId'
    @kite.auth = { authenticated: false }

    @forwardEvents @kite, ['open', 'close']


  connect: ->

    @emit 'message', "Connecting to rope over #{ROPE_SERVER}..."
    @kite.connect()


  getApi: ->

    return @api  if @api

    @api = {}

    @handleFunc 'rope.identified', (data, callback) ->

      @kite.logger.info('Identified with:', data)

      @kite.auth = data.auth
      @kite.environment = data.environment  if data.environment

      @kite.tell('count').then (totalNodes) =>
        @emit 'totalNodes', totalNodes

      @kite.tell('query').then (kites) =>

        for kite, i in kites
          if kite.id is @kite.id
            kites.unshift (kites.splice i, 1)[0]
            break
        @emit 'queryResult', kites

      @kite.tell 'subscribe', 'node.exec'
      @kite.tell 'subscribe', 'node.added'
      @kite.tell 'subscribe', 'node.removed'

      @emit 'ready'

    @handleFunc 'rope.identify', (id, callback) ->

      @kite.logger.info('Identify requested, doing now...', id)
      @emit 'message', 'Connected! Identify requested, doing now...'

      info =
        kiteInfo: @kite.getKiteInfo()
        api: Object.keys @getApi()
        docs: {}
        signatures:
          square: 'Number, Function'
          npm: 'String | Object, Function'
        useragent: navigator.userAgent

      callback null, info

    @handleFunc 'rope.error', (args) ->
      @kite.disconnect()  if args.disconnect

    @handleFunc 'rope.notify', (args) ->
      @emit 'notification', args

    @handleFunc 'kite.ping', (callback) ->
      callback null, 'pong'

    @handleFunc 'square', (number, callback) ->
      callback null, number * number
    , { write: yes }

    @handleFunc 'npm', (options, callback) ->

      # This needs to be removed ~ GG
      if 'string' is typeof options
        [ pkg, args ] = options.split "("
        args = [ args.replace(/\)$/, '').replace /\"/mg, '' ]
        [ pkg, method ] = pkg.split "."
      else
        { method, args = [] } = options ? {}
        pkg = options.package

      op_id = uuid()

      method = if method
      then "pkg.#{method}"
      else 'pkg'

      code = """
        import pkg from "#{pkg}"

        const op_id = "#{op_id}"
        const origin = "#{location.origin}"

        window.addEventListener('message', event => {

          if (event.origin != origin || event.data.op_id != op_id) {
            return
          }

          let res
          let error = null

          try {
            res = #{method}.apply(this, event.data.args)
          } catch (err) {
            error = err
          }

          event.source.postMessage({ op_id, error, res }, event.origin)

        }, false)
      """

      window.addEventListener 'message', (event) ->
        return if event.origin != "null" or event.data.op_id != op_id
        callback event.data.error, event.data.res

      bundle = Babel.transform(code, BABEL_OPTIONS)

      @npmSandbox.bundle bundle.code

      @npmSandbox.once 'modules', (modules) ->
        new kd.NotificationView
          title: "Running #{modules[0].name}"
          content:  modules[0].description
          duration: 2000
          type: 'tray'

      @npmSandbox.once 'bundleEnd', => kd.utils.wait 100, =>
        @npmSandbox.iframe.iframe.contentWindow.postMessage {
          args, op_id
        }, '*'

    @handleFunc 'eval', (code, callback) ->

      completed = false
      __op_id = uuid()

      code = Babel.transform(code, BABEL_OPTIONS).code

      code = """
        const __op_id = "#{__op_id}"
        const __origin = "#{location.origin}"

        const __getParent = new Promise(ok => {
          window.addEventListener('message', event => {
            if (event.origin != __origin || event.data.__op_id != __op_id) {
              return
            } else {
              ok(event)
            }
          }, false)
        })

        const rope = {
          return: (res, error) => {
            let message = { __op_id, error }
            if (!error) {
              message.res = res
            }
            __getParent.then(parent => {
              parent.source.postMessage(message, parent.origin)
            })
            return;
          },
          fail: (error) => {
            rope.return(null, error)
          }
        }

        try {
          #{code}
        } catch (err) {
          let { name, message, column, line } = err
          rope.fail({ name, message, column, line })
        }

      """

      window.addEventListener 'message', (event) ->
        return  if event.origin != "null" or event.data.__op_id != __op_id
        completed = true
        callback event.data.error, event.data.res
        __op_id = uuid() # to prevent multiple calls on same operation id

      bundle = Babel.transform(code, BABEL_OPTIONS)

      @npmSandbox.bundle bundle.code
      @npmSandbox.once 'bundleEnd', => kd.utils.wait 100, =>
        @npmSandbox.iframe.iframe.contentWindow.postMessage { __op_id }, '*'
        kd.utils.wait EVAL_TIMEOUT, ->
          callback {
            type: 'Timeout',
            message: """
              Operation timed out, did you call rope.return in your code?
            """
          } unless completed

    return @api

  handleFunc: (name, fn, options) ->

    if @api[name]?
      unless @api[name]._options.write
        return console.warn 'Method does not support updates!'
      options ?= @api[name]._options

    @api[name] = (args..., cb) =>

      @emit 'method.call', name

      if typeof cb is 'function'
        args = args.concat (res...) =>
          @emit 'method.response', name, res
          cb res...
      else
        args = args.concat cb

      fn.apply this, args

    @api[name]._options = options ? {}

    return name
