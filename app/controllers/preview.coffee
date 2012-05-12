Spine = require('spine')
_ = require('lib/underscore')
Swipe = require('lib/swipe')

class Preview extends Spine.Controller
  className: 'preview'
    
  events:
    'click img': 'close'
    'click .button.like': 'like'
    'click .button.dislike': 'dislike'
  
  constructor: ->
    super


    @content = $('<div />').addClass('content')
    @append @content

    images = ['/preview.jpg', '/preview2.jpg']
    
    @images = $('<div />').addClass('images')
    @wrapper = $('<ul />').addClass('wrapper').appendTo(@images)
    @content.append(@images)

    for image in images
      @_addImage image
    @images.find('li:first').css({display: 'block'})
    
    setTimeout =>
      swipe = new Swipe(@images.get(0))
    , 100
    
    
    buttonLike = $('<a />').addClass('button').addClass('like')
    buttonDislike = $('<a />').addClass('button').addClass('dislike')
    @content.append buttonLike
    @content.append buttonDislike

    @el.css({left: @left, top: @top, width: @width, height: @height, opacity: 0})

  _addImage: (path) ->  
    li = $('<li />')
    image = $('<img />').attr('src', path).addClass('preview').appendTo(li)
    @wrapper.append li
  
  show: ->
    @el.gfx({opacity: 1}, {duration: 300})
  
  like: ->
    alert 'liking'
  
  dislike: ->
    alert 'disliking'
  
  close: ->
    @didClose(@image) if @didClose?
  



module.exports = Preview