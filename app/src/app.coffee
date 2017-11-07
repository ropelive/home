kd = require 'kd.js'

injectApp = (app) -> (ctx, done) ->
  return done()  if ctx.app is app

  ctx.app = app

  done()


module.exports = class App extends kd.Object

  constructor: (options = {}) ->
    super options

    @router = options.router
    @root = options.root
    @user = options.user
    @ropeCounter = options.ropeCounter

    @attachRoutes options.routes


  attachRoutes: (routes) ->
    routes.forEach ({ path, onEnter, onExit, pre = [] }) =>
      handlers = [injectApp this].concat(pre).concat([onEnter])

      @router.addRoute path, handlers...

      if 'function' is typeof onExit
        @router.exitRoute path, onExit


  run: ->

    @root.appendToDomBody()
    @router.listen()

    return Promise.resolve this
