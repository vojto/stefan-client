Spine = require('spine')
require('spine.mobile')
_ = require('lib/underscore')
Config = require('config')

class Game extends Spine.Controller
  events:
    'tap .option': 'select'
    'tap .next': 'next'
    'tap .again': 'again'
  
  constructor: ->
    @el = $("#game").hide()
    super
    
  _showQuestion: (question) ->
    @el.empty()
    
    return unless question
    
    @question = question
    
    title = $("<h1 />").text("What's on this picture?")
    @append title

    image = $("<img />").attr('src', question.image)
    @append image
    
    for optionText in question.options
      options = $("<div />").addClass('options')
      @append options

      option = $("<div />").addClass('option').addClass('button').appendTo(options)
      option.text(optionText)
  
  select: (e) ->
    option = $(e.currentTarget)
    selected = option.text()
    
    if selected == @question.answer
      @_showCorrect()
    else
      @_showWrong()
  
  _showCorrect: ->
    @el.empty()
    
    result = $("<div />").addClass('result').addClass('correct')
    $("<h1 />").text("Correct!").appendTo(result)
    $("<div />").addClass("button").addClass("next").addClass("xl").text("Next question").appendTo(result)
    @append result
  
  _showWrong: ->
    @el.empty()
    
    result = $("<div />").addClass('result').addClass('wrong')
    $("<h1 />").text("Wrong!").appendTo(result)
    $("<div />").addClass("button").addClass("again").addClass("xl").text("Try again?").appendTo(result)
    @append result
  
  next: ->
    index = @questions.indexOf(@question) + 1
    index = 0 if index == @questions.length
    @_showQuestion(@questions[index])
  
  again: ->
    @_showQuestion(@question)
  
  toggle: ->
    @el.toggle()
  
  start: ->
    words = @app.knownWords
    
    @questions = []
    index = 0
    keys = _.keys(words)
    for word, hilight of words
      options = [word]
      
      total = 4
      total = keys.length if keys.length < total
      
      while options.length < total
         option = keys[Math.floor(Math.random()*keys.length)];
         options.push(option) unless _.include(options, option)
        
      options.sort -> 0.5 - Math.random()
      
      question =
        image: "#{Config.assets}/#{_.first(hilight.imageURL)}"
        options: options
        answer: word
      
      @questions.push(question)
    console.log @questions
    @next()

module.exports = Game