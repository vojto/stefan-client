Spine = require('spine')
require('spine.mobile')

class Game extends Spine.Controller
  events:
    'tap .option': 'select'
    'tap .next': 'next'
    'tap .again': 'again'
  
  constructor: ->
    @el = $("#game").hide()
    super
    
    paths = ['/preview.jpg', 'preview2.jpg']
    
    question1 =
      image: '/preview.jpg'
      options: ['Telescope', 'Planets', 'Studying', 'Stars']
      answer: 'Telescope'
    
    question2 =
      image: '/preview2.jpg'
      options: ['Car', 'City', 'Bridge', 'Forest']
      answer: 'Bridge'
    
    @questions = [question1, question2]
    
    @_showQuestion(question1)
    
  _showQuestion: (question) ->
    @el.empty()
    
    @question = question
    
    title = $("<h1 />").text("What's on this picture?")
    @append title

    image = $("<img />").attr('src', question.image)
    @append image
    
    for optionText in question.options
      options = $("<div />").addClass('options')
      @append options

      option = $("<div />").addClass('option').appendTo(options)
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
    $("<div />").addClass("button").addClass("next").text("Next question").appendTo(result)
    @append result
  
  _showWrong: ->
    @el.empty()
    
    result = $("<div />").addClass('result').addClass('wrong')
    $("<h1 />").text("Wrong!").appendTo(result)
    $("<div />").addClass("button").addClass("again").text("Try again?").appendTo(result)
    @append result
  
  next: ->
    index = @questions.indexOf(@question) + 1
    index = 0 if index == @questions.length
    @_showQuestion(@questions[index])
  
  again: ->
    @_showQuestion(@question)
  
  toggle: ->
    @el.toggle()

module.exports = Game