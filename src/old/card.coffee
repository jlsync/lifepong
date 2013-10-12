
$ = if jQuery? then jQuery else require('jquery')

class Card
  constructor: (arg1, arg2) ->
    if typeof arg1 is "string"
      @suit = arg1
      @number = arg2
    else
      @suit = arg1.suit
      @number = arg1.number

  is_picture: -> @number.match(/A|K|Q|J/)?

  toString: -> "#{@number} of #{@suit}"

  toJSON: -> { number: @number, suit: @suit }

  suit_p: ->
    switch @suit
      when "clubs"
        "♣"
      when "spades"
        "♠"
      when "hearts"
        "♥"
      when "diamonds"
        "♦"

  is: (card) -> @suit is card.suit and @number is card.number

  render: ->
    @$card?.remove()
    @$card = $("""
              <div class="card #{@suit}">
              <div class="number">
              #{@number}
              </div>
              <div class="smallsymbol">
              #{@suit_p()}
              </div>
              <div class="bigsymbol">
              #{@suit_p()}
              </div>
              <div class="smallsymbol rotate">
              #{@suit_p()}
              </div>
              <div class="number rotate">
              #{@number}
              </div>
              </div>
              """)
    @$card.data('card', this)
    @$card.draggable()

  show: -> @render().appendTo('body')


(exports ? window).Card = Card
