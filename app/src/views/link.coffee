kd = require 'kd.js'

module.exports = class Link extends kd.CustomHTMLView
  constructor: (options = {}, data) ->

    options.tagName = 'a'
    options.cssClass = kd.utils.curry 'link', options.cssClass
    options.attributes ?= {}
    options.attributes.href = options.to ? '#'

    super options, data


