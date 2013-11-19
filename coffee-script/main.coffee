requirejs.config
  baseUrl: "/js"

# main entry point
# this callback should have all global libraries defined as well
require ["Celestrium"], (Celestrium) ->
  # do stuff
  class ConfigView extends Backbone.View
    events:
      "keyup #assertions-value": "validate"
      "keyup #axes-value": "validate"
      "change #node-type-value": "validate"
      "click #btn-visualize": "visualize"

    render: () ->
      @validate()

    validate: () ->
      console.log "validating"
      assertionsValid = false
      try
        assertions = @getAssertions()
        throw "not array" unless _.isArray(assertions)
        throw "no assertions" unless assertions.length > 0
        _.each assertions, (assertion) ->
          throw "assertion #{assertion} not array" unless _.isArray(assertion)
          throw "assertion #{assertion} not length 3" unless assertion.length == 3
          _.each assertion, (cell) ->
            throw "cell #{cell} not string" unless _.isString(cell)
        assertionsValid = true
      catch error
        console.log error

      axesValid = false
      try
        axes = @getAxes()
        console.log axes
        throw "not array" unless _.isArray(axes)
        throw "no axes" unless axes.length > 0
        _.each axes, (numAxes) ->
          throw "not positive" unless numAxes > 0
          throw "not integer" unless parseInt(numAxes) == numAxes
        axesValid = true
      catch error
        console.log error

      @$("#assertions-validity")
        .toggleClass("valid", assertionsValid)
        .toggleClass("invalid", !assertionsValid)
        .text(if assertionsValid then "Yes" else "No")

      @$("#axes-validity")
        .toggleClass("valid", axesValid)
        .toggleClass("invalid", !axesValid)
        .text(if axesValid then "Yes" else "No")

      @$("#btn-visualize").attr("disabled", not assertionsValid or not axesValid)

    getAssertions: () ->
      return JSON.parse(@$("#assertions-value").val())

    getAxes: () ->
      return JSON.parse(@$("#axes-value").val())

    getNodeType: () ->
      return @$("#node-type-value").val()

    visualize: () ->
      assertions = @getAssertions()
      axes = @getAxes()
      nodeType = @getNodeType()
      @$el.remove()

      console.log nodeType
      provider = if nodeType == "concepts" then "ConceptProvider" else "AssertionProvider"

      # initialize the workspace with all the below plugins
      plugins =
        # these come with celestrium
        # their arguments should be specific to this data set
        "Layout":
          "el": document.querySelector "#celestrium"
          "title": "UAP"
        "KeyListener":
          document.querySelector "body"
        "GraphModel":
          "nodeHash": (node) -> node.text
          "linkHash": (link) -> link.source.text + link.target.text
        "GraphView": {}
        "Sliders": {}
        "ForceSliders": {}
        "Stats": {}
        "NodeSelection": {}
        "SelectionLayer": {}
        "NodeDetails": {}
        "LinkDistribution": {}
        # these are plugins i defined specific to this data set
        "DimSlider":
          [Math.min.apply(null, axes), Math.max.apply(null, axes)]
      console.log provider
      plugins[provider] =
        assertions: assertions
        axes: axes
      plugins["NodeSearch"] =
        prefetch: "get_nodes?hashValue=alpha"
      Celestrium.init plugins

  $ () ->
    new ConfigView
      "el": document.querySelector("#configuration")
    .render()