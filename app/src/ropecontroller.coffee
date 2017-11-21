kd = require 'kd.js'

Rope = require './rope'
KiteItem = require './kiteitem'
RopeSceneView = require './ropesceneview'

window.Rope = Rope

module.exports = class RopeController extends kd.ListViewController

  constructor: (options = {}, data = { items: [] }) ->

    options.itemClass = KiteItem
    options.selection = yes

    super options, data

    @counter = @getOption 'counter'

    @rope = new Rope
    window.rope = @rope
    window.kite = @rope.kite

    @rope.ready =>
      @rope.on 'notification', @bound 'handleChanges'
      @rope.on 'queryResult', @bound 'replaceAllItems'
      @rope.on 'totalNodes', (totalNodes) =>
        @counter.totalNodes = totalNodes.total
      @rope.on 'method.call', (name) =>
        @scene.addTransfer @connection, {
          color: 'white', size: 6, duration: 600
        }
      @rope.on 'method.response', =>
        @scene.addTransfer @connection, {
          color: 'yellow', size: 6, duration: 600, reverse: yes
        }

    @rope.on 'open',  => @emit 'status', 'Connected!'
    @rope.on 'close', => @emit 'status', 'Reconnecting...'

    view = @getView()
    view.setClass 'kite-list'

    listView = @getListView()

    view.addSubView @sceneView = new RopeSceneView
    @scene = @sceneView.getScene()

    view.addSubView new KiteItem
      cssClass: 'header'
      delegate: listView
    , {
      id: 'ID',
      kiteInfo: {
        name: 'Name',
        environment: 'Environment'
      }
    }

    listView.on 'run', (item, method, args...) =>

      { dia, data } = item

      options =
        duration  : 1000
        text      : method
        color     : '#f4d93f'
        font      : '14px Helvetica'
        textAlign : 'right'
        reverse   : yes

      id = @scene.addTransfer @connection, options

      @scene.once "Transfer-#{id}-Done", =>

        options.color     = 'lightgreen'
        options.reverse   = no
        options.textAlign = 'left'

        id = @scene.addTransfer dia._connection, options

        @scene.once "Transfer-#{id}-Done", =>

          @rope.kite.tell('run', {
            kiteId: data.id
            method, args
          }).then (reply) =>

            options.text    = reply
            options.reverse = yes
            id = @scene.addTransfer dia._connection, options

            @scene.once "Transfer-#{id}-Done", =>

              options.color     = '#f4d93f'
              options.reverse   = no
              options.textAlign = 'right'
              id = @scene.addTransfer @connection, options

              return if /^(rope|kite)\./.test method

              @scene.once "Transfer-#{id}-Done", =>
                reply = JSON.stringify(reply) if "object" is typeof reply
                alert("#{reply}")


    @scene.on 'selected', @bound 'selectItem'


  connect: ->

    @emit 'status', 'Connecting...', 0
    @rope.connect()


  handleChanges: (change) ->

    switch change.event
      when 'node.exec'
        if ((source = @itemsIndexed[change.data['from']]) && \
            (target = @itemsIndexed[change.data['to']]))

          source = source.dia._connection
          target = target.dia._connection

          tid = @scene.addTransfer source, {
            color: 'red', size: 6, duration: 500, reverse: yes
          }
          @scene.once "Transfer-#{tid}-Done", =>
            @scene.addTransfer target, {
              color: 'green', size: 6, duration: 500
            }

      when 'node.added'
        @addItem change.kiteInfo
      when 'node.removed'
        @removeItem @itemsIndexed[change.kiteInfo.id]


  replaceAllItems: ->

    @counter.nodes = 0
    @scene.removeAllNodes()

    super

    @scene.highlightLines()


  addItem: (itemData) ->

    item = super itemData

    # if @counter.length < 50

    dia = @scene.addNode item, activeKite = itemData.id is @rope.kite.id
    @connection = dia._connection  if activeKite

    item.dia = dia

    @counter.nodes++

    return item


  removeItem: (item) ->

    @counter.nodes--
    @scene.removeNode item.dia

    super item
