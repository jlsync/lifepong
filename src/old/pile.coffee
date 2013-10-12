
$ = if jQuery? then jQuery else require('jquery')
EE = if EventEmitter? then EventEmitter else require('events').EventEmitter

class Pile extends EE
  constructor: (data) ->
    @fromJSON data
    @$cards = $('<div class="cards"/>')
    @$pile = $("""
              <div class="pile">
              <div class="name">#{@name}</div>
              </div>
              """)
    @$pile.append @$cards

  add: (card) ->
    @cards.push(card)
    card.location = @

  remove: (card) -> @cards = (c for c in @cards when not c.is card)

  toJSON: -> name: @name, cards: (c.toJSON() for c in @cards), constructor: @constructor.name

  fromJSON: (data) ->
    @name = data.name || ''
    @cards = []
    for c in (data.cards or [])
      @add new Card(c)

  dropped_on: (event, ui) =>
    card = ui.draggable.data('card')
    @emit('played', card)
    # via server, via  @show()

  render: ->
    @$cards?.empty()
    @$cards.append(card.render()) for card in @cards
    @$pile

  show: ->
    if @$pile.closest('body').length == 0
      @$pile.appendTo(@$game or 'body')
      @$pile.droppable drop: @dropped_on
      @$pile.data('pile', this)
    @render()


(exports ? window).Pile = Pile
