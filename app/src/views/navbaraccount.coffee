kd = require 'kd.js'

UserInfo = require './userinfo'
Logout = require './logout'

module.exports = class NavbarAccount extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.cssClass = 'navbar-account'

    super options, data

    @userInfo = new UserInfo {}, data
    @logout = new Logout


  pistachio: ->
    """
    {{> @userInfo}}
    {{> @logout}}
    """
