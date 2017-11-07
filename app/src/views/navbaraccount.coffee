kd = require 'kd.js'

UserInfo = require './userinfo'
Logout = require './logout'

module.exports = class NavbarAccount extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.cssClass = 'navbar-account'

    super options, data

    @userInfo = new UserInfo {
      click: @bound 'onUserInfoClick'
    }, data

    @logout = new Logout


  onUserInfoClick: ->

    # FIXME: can't find a quicker solution yet, this is so bad. ~Umut
    global.app.router.handleRoute '/profile'


  pistachio: ->
    """
    {{> @userInfo}}
    {{> @logout}}
    """
