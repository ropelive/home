kd = require 'kd.js'

module.exports = class Message extends kd.CustomHTMLView
  constructor: (options = {}, data) ->
    options.cssClass = 'message'
    options.partial ?= 'Loading...'
    super options, data
