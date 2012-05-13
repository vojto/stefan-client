Spine = require('spine')
require('spine.mobile')
_ = require('lib/underscore')
Config = require('config')

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
    plus = $("<div />").addClass('button').addClass('plus').appendTo(right)
    
    @input = $("<input />").attr('type', 'file').appendTo(plus)
    @input.bind 'change', @upload
    

  smaller: ->
    @app.smaller()
  
  larger: ->
    @app.larger()
  
  game: ->
    @app.showGame()
  
  upload: (e) =>
    files = e.originalEvent.target.files
    file = _.first(files)
    return unless file
    
    if file.type == 'text/plain'
      reader = new FileReader
      reader.onload = (e) =>
        data = e.target.result
        @app.showFile(data)
      reader.readAsText(file)
    else
      formData = new FormData
      formData.append(file.name, file)
      xhr = new XMLHttpRequest
      xhr.open 'POST', "#{Config.server}/upload", true
      xhr.onload = (e) =>
        console.log "finished uploading file", e
        console.log xhr.responseText
      xhr.send(formData)
      
    

module.exports = Navigation