kd = require 'kd.js'

module.exports = k = (tagName, options, data) ->
  options = Object.assign {}, options, { tagName }

  new kd.CustomHTMLView options, data
