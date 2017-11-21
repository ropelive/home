kd = require 'kd.js'

module.exports = class UserInfo extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'a'
    options.attributes =
      href: '/profile'
    options.cssClass = 'user-info'
    options.size ?= 30

    super options, data

    @photo = new kd.CustomHTMLView
      tagName: 'img'
      attributes:
        src: data.photo
        style: "width: #{options.size}px; height: #{options.size}px;"


  pistachio: ->
    """
    {.photo{> @photo }}
    {.display-name{ #(username) }}
    """
