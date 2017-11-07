kd = require 'kd.js'
RopeScene = require './ropescene'

module.exports = class RopeSceneView extends kd.View

  constructor: (options = {}, data) ->

    # TODO use options ^^
    super
      cssClass: 'rope-scene-view'
    , data

    @addSubView wrapper = new kd.View
      cssClass : 'wrapper'

    wrapper.addSubView @scene = new RopeScene


  viewAppended: ->

    super

    @addSubView zoomControls = new kd.CustomHTMLView
      cssClass   : "zoom-controls"

    zoomControls.addSubView zoomOut = new kd.CustomHTMLView
      tagName    : "a"
      cssClass   : "zoom-control zoomout"
      partial    : "-"
      click      : -> handle.setValue handle.value - 0.1

    zoomControls.addSubView @slider = new kd.SliderBarView
      cssClass   : 'zoom-slider'
      minValue   : 0.3
      maxValue   : 1.0
      interval   : 0.1
      width      : 120
      snap       : no
      snapOnDrag : no
      drawBar    : yes
      showLabels : no
      handles    : [1]

    handle = @slider.handles.first

    zoomControls.addSubView zoomIn = new kd.CustomHTMLView
      tagName    : "a"
      cssClass   : "zoom-control zoomin"
      partial    : "+"
      click      : -> handle.setValue handle.value + 0.1

    zoomControls.addSubView resetButton = new kd.ButtonView
      cssClass: 'reset-button'
      title: 'reset'
      callback: =>
        @getScene().resetNodes()
        handle.setValue 1

    @slider.on 'ValueIsChanging', (value) =>
      @getScene().setScale value


  getScene: -> @scene
