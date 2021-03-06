kd = require 'kd.js'

module.exports = class LoginWithGithub extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'button'
    options.cssClass = 'login-with-github'
    options.partial = 'Login with GitHub'

    super options, data

  click: (event) ->
    kd.utils.stopDOMEvent event
    location.href = '/auth/github'
