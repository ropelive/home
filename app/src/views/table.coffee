kd = require 'kd.js'

module.exports = class Table extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'table'
    options.cssClass = 'table'

    super options, data

    { columns } = options

    items = data

    @header = new kd.CustomHTMLView
      tagName: 'thead'
      cssClass: 'table-header'

    @header.addSubView headerRow = new kd.CustomHTMLView
      cssClass: 'table-row'
      tagName: 'tr'

    columns.forEach (column, index) ->
      headerRow.addSubView new kd.CustomHTMLView
        tagName: 'th'
        cssClass: "table-column-header #{column.cssClass or ''}"
        partial: column.title
        attributes: { style: "width: #{column.width}" }

    @body = new kd.CustomHTMLView
      tagName: 'tbody'

    items.forEach (item, rowIndex) =>
      @body.addSubView row = new kd.CustomHTMLView
        tagName: 'tr'
        cssClass: 'table-row'

      columns.forEach (column, colIndex) =>
        row.addSubView col = new kd.CustomHTMLView
          cssClass: "table-cell #{column.cssClass or ''}"
          tagName: 'td'

        if column.accessor
          col.addSubView new kd.CustomHTMLView
            tagName: 'span'
            partial: item[column.accessor]

        else if column.render
          col.addSubView column.render item, rowIndex, colIndex


  pistachio: ->
    """
    {{> @header}}
    {{> @body}}
    """
