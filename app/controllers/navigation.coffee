Spine = require('spine')
require('spine.mobile')

class Navigation extends Spine.Controller
  events:
    'tap .smaller': 'smaller'
    'tap .larger': 'larger'
    'tap .game': 'game'
  
  constructor: ->
    @el = $("#navigation")
    super
    
    left = $("<div />").addClass('fl')
    @append left
    right = $("<div />").addClass('fr')
    @append right
    
    smaller = $("<a />").addClass('button').addClass('smaller').appendTo(left)
    larger = $("<a />").addClass('button').addClass('larger').appendTo(left)
    game = $("<a />").addClass('button').addClass('game').appendTo(right)
    plus = $("<a />").addClass('button').addClass('plus').appendTo(right)

  smaller: ->
    @app.smaller()
  
  larger: ->
    @app.larger()
  
  game: ->
    @app.showGame()

module.exports = Navigation