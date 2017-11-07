kd = require 'kd.js'
CodeEditor = require './editor'

module.exports = class KiteDetails extends kd.View

  constructor: (options = {}, data) ->

    options = kd.utils.extend
      cssClass : 'details'
    , options

    data ?= options.delegate.getData()

    super options, data

    @pingButton   = new kd.ButtonView
      title       : 'ping'
      callback    : =>
        @delegate.getDelegate().emit 'run', @delegate, 'kite.ping'

    @cancelButton = new kd.ButtonView
      title       : 'cancel'
      callback    : =>
        @delegate.removeHighlight()

    { api, _type } = @getData()

    @setClass _type

    @apiButtons = new kd.View
      cssClass: 'api buttons'
      partial : if api.length > 0 then '<h2>API:</h2><hr />' else ''

    api.forEach (method) =>
      return if /^(rope|kite)\./.test method

      @apiButtons.addSubView new kd.ButtonView
        title: method
        callback: =>
          input = prompt("""
            input for #{method}
            you can also run this with;

            curl -sX POST \
              https://run.rope.live/#{@getData().kiteInfo.id}/#{method} \
              -H 'content-type: application/json' \
              -d '[]'
          """)

          return unless input

          @delegate.getDelegate().emit 'run', @delegate, method, input

  pistachio: ->
    """
      <cite></cite>
      {h3{#(kiteInfo.name)}}
      Running on {{#(kiteInfo.environment)}}
      <div class='buttons'>
        {{> @cancelButton }}
        {{> @pingButton }}
      </div>
      {{> @apiButtons}}
    """
