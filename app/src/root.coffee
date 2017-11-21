kd = require 'kd.js'

Header = require './views/header'

module.exports = class Root extends kd.View

  constructor: (options = {}, data) ->
    options.cssClass = 'root'
    super options, data

    @pages = {}
    @visiblePage = null

    @header = new Header { user: data.user }
    @pageContainer = new kd.CustomHTMLView { cssClass: 'page-container' }


  makePage: (name, context) ->
    { View, options, data } = @options.pages[name]
    options = Object.assign { context }, options
    @pages[name] = new View(options, data)


  showPage: (name, context) ->

    unless @options.pages[name]
      return

    { pages } = @getOptions()

    page = @pages[name] ? @makePage name, context

    return if @visiblePage is page

    @visiblePage?.detach()
    @pageContainer.addSubView page
    @visiblePage = page


  pistachio: ->
    """
    {{> @header}}
    {{> @pageContainer}}
    """
