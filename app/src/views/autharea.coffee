kd = require 'kd.js'

NavbarAccount = require './navbaraccount'
LoginWithGithub = require './loginwithgithub'

module.exports = class AuthArea extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.cssClass = 'auth-area'

    super options, data

    @addSubView if options.user
    then new NavbarAccount {}, options.user
    else new LoginWithGithub
