{ Router } = require 'sixtysix'
kd = require 'kd.js'

Root = require './root'
App = require './app'
Routes = require './routes'
RopeController = require './ropecontroller'

HomePage = require './pages/home'
TokensPage = require './pages/tokens'

{ user } = _globals

start = ->

  kd.registerSingleton 'router', router = new Router

  ropeCounter = new kd.Data {
    nodes: 0
    totalNodes: 0
  }, { maxDepth: 1 }

  global.app = app = new App
    user: user
    router: router
    routes: Routes
    ropeCounter: ropeCounter
    root: new Root {
      pages:
        home: { View: HomePage }
        tokens: { View: TokensPage }
    }, { counter: ropeCounter, user }


  app.run().then -> console.log 'app is running'

start()
