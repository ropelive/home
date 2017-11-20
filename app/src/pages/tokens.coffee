kd = require 'kd.js'

apiClient = require '../apiclient'

TokenTable = require '../views/tokentable'
Message = require '../views/message'
k = require '../views/k'

module.exports = class TokensPage extends kd.CustomHTMLView

  constructor: (options = {}, data) ->
    options.cssClass = 'page profile-page container'
    super options, data

    @tokenTable = null

    @addSubView k 'header', { cssClass: 'page-header', partial: 'Tokens' }


  viewAppended: ->
    super
    @addSubView @message = new Message

    @fetchTokens().then => @message.destroy()


  fetchTokens: ->

    @tokenTable?.destroy()

    apiClient
      .get '/tokens'
      .then (response) -> response.data
      .then (tokens) =>
        @addSubView @tokenTable = new TokenTable {
          tokens,
          onAction: @bound 'onAction'
          onNewToken: @bound 'onNewToken'
        }
      .catch (err) =>
        @message.updatePartial 'Login required'


  onAction: (actionType, token) ->

    switch actionType
      when 'revoke'
        apiClient
          .delete "/tokens/#{token.value}"
          .then @bound 'fetchTokens'


  onNewToken: (label) ->
    options = {}
    options.label = label  if label
    apiClient
      .post '/tokens', options
      .then @bound 'fetchTokens'
