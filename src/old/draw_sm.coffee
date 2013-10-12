
jQuery ?= require('jquery')


# Graph from dracula

class DrawSm
  constructor: (@sm) ->
    @graph = new Graph()
    @nodes = {}
    for state_name of @sm.states
      @nodes[state_name] = @graph.addNode state_name
    for event_name, event of @sm.events
      for from, to of event.transitions
        @graph.addEdge  from, to,
          directed: true
          label: event_name

  draw: (dom_id) ->
    @layouter = new Graph.Layout.Spring(@graph)
    $d = jQuery('#dom_id')
    @renderer = new Graph.Renderer.Raphael(dom_id, @graph, $d.width(), $d.height())

  redraw: ->
    @layouter.layout()
    @renderer.draw()


(exports ? window).DrawSm = DrawSm
