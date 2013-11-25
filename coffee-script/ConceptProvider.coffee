# interface to uap's semantic network
# nodes are concepts from a semantic network
# links are the relatedness of two concepts
localStorage.clear()
define ["DataProvider"], (DataProvider) ->

  # minStrength is the minimum similarity
  # two nodes must have to be considered linked.
  # this is evaluated at the minimum dimensionality
  numNodes = 25

  class ConceptProvider extends DataProvider

    constructor: (@options) ->
      data =
        hashValue: @options.hash
        assertions: JSON.stringify(@options.assertions)
        axesList: JSON.stringify(@options.axes)
        nodeType: "concepts"
      @ajax "create_kb", data, @options.callback

    init: (instances) ->
      @dimSlider = instances["DimSlider"]
      super(instances)

    getLinks: (node, nodes, callback) ->
      data =
        hashValue: @options.hash
        node: JSON.stringify(node)
        otherNodes: JSON.stringify(nodes)
      @ajax "get_edges", data, (arrayOfCoeffs) ->
        callback _.map arrayOfCoeffs, (coeffs, i) ->
          coeffs: coeffs

    getLinkedNodes: (nodes, callback) ->
      data =
        hashValue: @options.hash
        nodes: JSON.stringify(nodes)
        numNodes: numNodes
      @ajax "get_related_nodes", data, callback

    # initialize each link's strength before being added to the graph model
    linkFilter: (link) ->
      @dimSlider.setLinkStrength(link)
      return true
