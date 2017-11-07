kd = require 'kd.js'
AuthArea = require './autharea'

module.exports = class Header extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'header'
    options.cssClass = 'main-header'

    super options, data

    { user } = options

    @authArea = new AuthArea { user }


  pistachio: ->
    """
    <div class='main-header--left'>
      <a class='page-title' href='/'><h1>Rope Universe</h1></a>
    </div>
    <div class='main-header--right'>
      {{> @authArea}}
    </div>
    """
