kd = require 'kd.js'

module.exports = class RopeCount extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'div'
    options.cssClass = 'counter'

    super options, data


  pistachio: ->
    """
    {{ #(nodes) }} node{{ #(nodes != 1 ? `s`) }} connected
    """
