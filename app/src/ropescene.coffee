kd = require 'kd.js'
Hammer = require 'hammerjs'
window.kd = kd

module.exports = class RopeScene extends kd.DiaScene

  constructor: (options = {}, data) ->

    # TODO use options ^^
    super {
      cssClass        : 'rope-scene'
      lineWidth       : 2
      lineColor       : '#3c4f63'
      lineColorActive : '#f4d93f'
      curveDistance   : 100
      prependCanvas   : yes
    }, data


  viewAppended: ->

    super

    wc = kd.singletons.windowController
    hm = new Hammer @getElement()

    hm.on 'pan', (event) =>
      return  if event.pointerType is 'mouse'
      if event.isFinal
        wc.dragView = this
        return wc.unsetDragView event
      if @kiteContainer isnt wc.dragView
        event.stopPropagation = kd.noop
        @emit 'mousedown', event
      else
        wc.dragView.drag event, { x: event.deltaX, y: event.deltaY }

    hm.get('pinch').set({ enable: true })

    scale = 1
    hm.on 'pinchend', (event) =>
      scale = @scale
    hm.on 'pinch', (event) =>
      @setScale scale * event.scale

    @ropeContainer = @addContainer (new kd.DiaContainer {
      cssClass  : 'rope-container'
      draggable : no
    }), { x: 0, y: 0 }

    @ropeContainer.setScale = kd.noop

    @kiteContainer = @addContainer (new kd.DiaContainer {
      cssClass     : 'kite-container'
      draggable    :
        handle     : this
    }), { x: 0, y: 0 }

    @kiteContainer.mouseDown = kd.View::mouseDown

    @ropeDia = @ropeContainer.addDia (new kd.DiaObject {
      cssClass     : 'rope-dia'
      draggable    : no
      joints       : ['top']
      staticJoints : ['top']
    })

    kd.utils.defer @bound 'buildPositionIndex'
    @listenWindowResize()


  getClass = (env) ->

    return 'firefox'  if /firefox/i.test env
    return 'safari'   if /safari/i.test env
    return 'chrome'   if /chrom/i.test env
    return 'opera'    if /opera/i.test env
    return 'edge'     if /^edge/i.test env
    return 'js'       if /^node\.js/i.test env
    return 'go'       if /^go/i.test env
    return ''


  setLRClass: (node, x, w) ->

    center = w / 2 - iw / 2

    node.unsetClass 'right left'
    if x > center + 10
      node.setClass 'right'
    else if x < center - 10
      node.setClass 'left'
    else
      node.setClass 'current'


  iw = 90
  f  = Math.floor

  guessNodePosition: (index, w, h) ->

    nc = index + 1
    pt = h / 4 # 120
    sp = w / 10
    sh = h / 10
    rw = w / sp
    rt = f nc / rw
    ic = f nc / 2
    zp = w / 2 - iw / 2

    x = if 0 is nc % 2
      zp + (sp * ic - (ic * rt)) - (zp * rt)
    else
      zp - (sp * ic - (ic * rt)) + (zp * rt)

    y = pt + sh * rt

    return { x, y, index }


  addNode: (item, current = no) ->

    nodeData = item.getData()
    nodeData._type = getClass nodeData.kiteInfo.environment

    c = @getFirstAvailablePosition()

    parent = this
    node = @kiteContainer.addDia (new kd.DiaObject {
      cssClass     : "kite-dia animate #{nodeData._type}"
      draggable    : yes
      bind         : 'mouseover mouseleave'
      joints       : ['bottom']
      staticJoints : ['bottom']
      partial      : '<cite/>'
      click        : ->
        parent.emit 'selected', item
    }, nodeData), { x: c.x, y: @getHeight() + 100 }

    node._index = c.index

    node.mouseOver = ->
      item.setClass 'hover'

    node.mouseLeave = ->
      item.unsetClass 'hover'

    @setLRClass node, c.x, @getWidth()

    node.on 'DragStarted', =>
      @startAutoUpdate()
      kd.utils.wait 2000, => @stopAutoUpdate()
      node.setClass 'dragInAction'

    node.on 'DragFinished', =>
      @startAutoUpdate 1000
      node.unsetClass 'dragInAction'

    node.on 'DragInAction', (x) =>
      current = node.dragState.direction.current.x
      if current isnt node._direction
        node._direction = current
        node.unsetClass 'right left'
        node.setClass current

    kd.utils.wait 400, =>
      @startAutoUpdate 1600
      node.setY c.y
      kd.utils.wait 1000, ->
        node.unsetClass 'animate'

    connection = @connect { dia: @ropeDia, joint: 'top' }, \
                          { dia: node,     joint: 'bottom' }, no

    if current
      connection.options.lineColor = '#f4d93f'
      # connection.options.lineWidth = 4

    node._connection = connection

    return node


  removeNode: (node) ->

    return  unless node

    node.setClass 'animate'
    node.setY -@getHeight()

    @deleteConnection node._connection
    @releasePositionForNode node._index

    kd.utils.defer =>
      @startAutoUpdate 1000
      kd.utils.wait 1000, node.bound 'destroy'


  removeAllNodes: ->

    @removeNode node  for _, node of @kiteContainer.dias


  releasePositionForNode: (index) ->

    @positions[index][0] = false


  lockPositionForNode: (index) ->

    @positions[index][0] = true
    return @positions[index][1]


  getFirstAvailablePosition: ->

    for pos, i in @positions when pos[0] is false
      return @lockPositionForNode i


  buildPositionIndex: ->

    [ w, h ] = [ @getWidth(), @getHeight() ]
    @positions = [0..200].map (i) =>
      pos = @guessNodePosition i, w, h
      [ inUse = false, pos ]


  resetNodes: (animate = yes) ->

    @startAutoUpdate 400

    @kiteContainer.setX 0
    @kiteContainer.setY 0

    @kiteContainer.setClass 'onreset'  if animate

    @buildPositionIndex()
    w = @getWidth()

    Object.keys(@kiteContainer.dias).forEach (dia, index) =>

      dia = @kiteContainer.dias[dia]

      c = @lockPositionForNode index

      dia.setX c.x
      dia.setY c.y

      dia._index = c.index

      @setLRClass dia, c.x, w

    return  unless animate

    kd.utils.wait 400, =>
      @kiteContainer.unsetClass 'onreset'
      @updateScene()


  handleLineRequest: -> no


  _windowDidResize: kd.utils.throttle 50, -> @resetNodes animate = no

