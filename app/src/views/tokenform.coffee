kd = require 'kd.js'

Input = require './input'

module.exports = class TokenForm extends kd.CustomHTMLView

  constructor: (options = {}, data) ->

    options.tagName = 'form'
    options.cssClass = 'token-form'
    options.bind = 'submit'
    super options, data

    @input = new Input
      cssClass: 'token-label'
      inline: yes
      fluid: yes
      attributes: { placeholder: 'Token label...' }

    @button = new kd.CustomHTMLView
      tagName: 'button'
      cssClass: 'bordered'
      partial: 'Create new token'


  submit: (event) ->
    kd.utils.stopDOMEvent event
    @options.onSubmit @input.$().val()


  pistachio: ->
    """
    {{> @input}}
    {{> @button}}
    """
