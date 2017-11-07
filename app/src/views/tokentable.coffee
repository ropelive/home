kd = require 'kd.js'

Table = require './table'
Link = require './link'
TokenForm = require './tokenform'

module.exports = class TokenTable extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.cssClass = 'token-table'
    super options, data

    { tokens } = options

    tableOptions =
      columns: [
        { title: 'Label', accessor: 'label', width: '35%' }
        { title: 'Value', accessor: 'value', width: '50%' }
        {
          title: 'Actions'
          cssClass: 'text-right'
          width: '15%'
          render: (item, rowIndex, colIndex) ->
            new Link
              cssClass: 'red'
              partial: 'revoke'
              click: (event) ->
                kd.utils.stopDOMEvent event
                options.onAction 'revoke', item
        }
      ]

    @addSubView new Table tableOptions, tokens
    @addSubView new TokenForm { onSubmit: options.onNewToken }
