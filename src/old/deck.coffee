
Card ?= require('./card').Card

class Deck
  constructor: ->
    @cards = []
    suits = ['hearts', 'clubs', 'diamonds', 'spades']
    numbers = ['A'].concat (num.toString() for num in [2..10]).concat(['J','Q','K'])
    
    for suit in suits
      for number in numbers
        @cards.push new Card suit, number

  shuffle: -> @cards.sort -> Math.random() - 0.5

  pick_a_card: -> @cards[Math.floor(Math.random() * @cards.length)]

  deal: (n = 1) -> (@cards.shift() for i in [0...n])



(exports ? window).Deck = Deck
