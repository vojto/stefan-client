Spine = require('spine')

class Preview extends Spine.Controller
  className: 'preview'
    
  events:
    'click img': 'close'
    'click .button.like': 'like'
    'click .button.dislike': 'dislike'
  
  constructor: ->
    super

    content = $('<div />').addClass('content')
    @append content
  
    image = $('<img />').attr('src', '/preview.jpg').addClass('preview')
    content.append image
    
    buttonLike = $('<a />').addClass('button').addClass('like')
    buttonDislike = $('<a />').addClass('button').addClass('dislike')
    content.append buttonLike
    content.append buttonDislike

    @el.css({left: @left, top: @top, width: @width, height: @height, opacity: 0})
  
  show: ->
    @el.gfx({opacity: 1}, {duration: 300})
  
  like: ->
    alert 'liking'
  
  dislike: ->
    alert 'disliking'
  
  close: ->
    @didClose(@image) if @didClose?


module.exports = Preview