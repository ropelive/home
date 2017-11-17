kd = require 'kd.js'

{ API_URL } = process.env

module.exports = class Logout extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'button'
    options.cssClass = 'logout-link'
    options.partial = 'Logout'

    super options, data


  click: (event) ->
    kd.utils.stopDOMEvent event

    location.href = "#{API_URL}/logout"

