kd = require 'kd.js'

module.exports = class Input extends kd.CustomHTMLView

  constructor: (options = {}, data) ->
    { cssClass = '', inline = no, fluid = no } = options

    cssClass = kd.utils.curry cssClass, 'input'
    cssClass = kd.utils.curry cssClass, 'inline-input'  if inline
    cssClass = kd.utils.curry cssClass, 'fluid-input'  if fluid

    options.tagName = 'input'
    options.cssClass = cssClass

    super options, data
