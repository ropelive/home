kd = require 'kd.js'
KiteDetails = require './kitedetails'

module.exports = class KiteItem extends kd.ListItemView

  constructor: (options = {}, data) ->

    options.cssClass = kd.utils.curry 'kite-item', options.cssClass
    options.bind = 'mouseover mouseleave'

    super options, data


  partial: ->

    { id, kiteInfo: { name, environment, hostname }} = @getData()
    """
      <div class='item'>
        <div title="#{id}">#{id[...13]}</div>
        <div title="#{name}">#{name}</div>
        <div title="#{environment}">#{environment}</div>
      </div>
    """

  getItemDataId: -> @getData().id


  mouseOver: ->

    @dia?.setClass 'hover'


  mouseLeave: ->

    @dia?.unsetClass 'hover'


  highlight: ->

    super

    @kiteDetails ?= @addSubView new KiteDetails delegate: this
    # kd.utils.defer => @getElement().scrollIntoView()
    @dia?.setClass 'selected'
    @dia?.emit 'DiaObjectClicked'



  removeHighlight: ->

    super

    @dia?.unsetClass 'selected'
