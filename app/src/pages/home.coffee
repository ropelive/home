kd = require 'kd.js'

RopeController = require '../ropecontroller'
RopeCount = require '../views/ropecount'

module.exports = class HomePage extends kd.CustomHTMLView

  constructor: (options = {}, data) ->
    options.cssClass = 'page home-page'
    super options, data

    { ropeCounter } = options.context.app

    @controller = new RopeController { counter: ropeCounter }

    @addSubView @controller.getView()
    @addSubView view = new kd.CustomHTMLView { cssClass: 'home-rope-count' }
    view.addSubView new RopeCount {}, ropeCounter


  viewAppended: ->
    super
    @controller.connect()


  status: do (banner = null) -> (title, duration = 3000) ->

    banner?.notificationSetTimer 1
    banner = new kd.NotificationView {
      title, duration, type: 'tray'
    }
