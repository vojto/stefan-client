Spine = require('spine')

class Preview extends Spine.Controller
  className: 'preview'
  
  constructor: ->
    super
    @image = image
  
    image = $('<img />').attr('src', '/preview.jpg').addClass('preview')
    @append image

    @el.css({left: @left, top: @top, opacity: 0})
  
  show: ->
    @el.gfx({opacity: 1}, {duration: 300})


module.exports = Preview