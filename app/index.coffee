require('lib/setup')
require('lib/jquery_frame')
require('gfx')

text = require('./phrases')
Spine = require('spine')
_     = require('lib/underscore')

Preview = require('controllers/preview')

IMAGE_HEIGHT = 100
IMAGE_MARGIN_TOP = 10
IMAGE_MARGIN_LEFT = 10
IMAGE_WIDTH = 130

# TODO:
# - Deselecting phrase by tapping somewhere else

class App extends Spine.Controller
  events:
    'click .phrase': 'select'
    'touchend .phrase': 'select'
    'click .image': 'open'
  
  constructor: ->
    super
    
    text = text.replace /\.$/, ''
    phrases = text.split /\.\s*/
    
    for phrase in phrases
      phrase = phrase + ". "
      el = $("<span class='phrase' />").text(phrase)
      @append el
    
    @canvas = $("canvas").get(0)
    $("canvas").attr(width: $(document).width(), height: $(document).height())
    ctx = @canvas.getContext("2d")
    ctx.fillStyle = "rgba(248, 248, 192, 0.35)"
    @context = ctx
    
  # Selecting
  # ---------------------------------------------------------------------------
    
  select: (e) ->
    @_deselect()
    phrase = $(e.currentTarget)
    text = phrase.text()
    @_hilight(phrase)

    meawords = ["study", "night skies", "telescopes", "midnight", "planets"]    
    for meaword in meawords
      text = text.replace meaword, '<span class="hilight">' + meaword + '</span>'
    phrase.html(text)
    hilights = @_hilightsDict(phrase)

    @_images(phrase, hilights)    

  _hilightsDict: (phrase) ->
    hilights = {}
    for hilight in phrase.find("span.hilight")
      hilight = $(hilight)
      hilights[hilight.text()] = hilight
    hilights
    
  _hilight: (phrase) ->
    @el.find('.phrase').removeClass('selected')
    phrase.addClass("selected")
    $("body").addClass("selected")
    
  _deselect: =>
    $("body").removeClass("selected")
    phrases = @$(".phrase")
    for phrase in phrases
      phrase = $(phrase)
      phrase.html(phrase.text())
    @$(".image").remove()
    
  # Showing images
  # ---------------------------------------------------------------------------
  
  _images: (phrase, hilights) ->
    phraseFrame = phrase.frame()

    edges = @_allEdges(phrase, hilights)
    balancedEdges = @_balanceEdges(edges)

    @context.clearRect(0, 0, @canvas.width, @canvas.height)
    $(@canvas).gfx(opacity: 0, {duration: 0, queue: false})
    @_imagesAdded = 0

    topOffset = phraseFrame.top - (IMAGE_HEIGHT + IMAGE_MARGIN_TOP)
    @_addHorizontalImages(hilights, balancedEdges.top, topOffset, 'top')
    bottomOffset = (phraseFrame.top+phraseFrame.height) + IMAGE_MARGIN_TOP
    @_addHorizontalImages(hilights, balancedEdges.bottom, bottomOffset, 'bottom')
    leftOffset = phraseFrame.left - (IMAGE_WIDTH + IMAGE_MARGIN_LEFT)
    @_addVerticalImages(hilights, balancedEdges.left, leftOffset, 'left')
    rightOffset = (phraseFrame.left+phraseFrame.width) + IMAGE_MARGIN_LEFT
    @_addVerticalImages(hilights, balancedEdges.right, rightOffset, 'right')
    
    setTimeout ->
      $(@canvas).gfx({opacity: 1}, {duration: 1000, queue: false})
    , 1000

  _addHorizontalImages: (hilights, selectedHilights, offset, direction) ->
    parsedHilights = []
    for hilightName in selectedHilights
      hilight = hilights[hilightName]
      left = hilight.frame().left
      left -= (IMAGE_WIDTH - hilight.frame().width)/2
      hilight.data('imagePosition', {left: left, top: offset})
      hilight.data('direction', direction)
      parsedHilights.push(hilight)
    @_shiftImages(parsedHilights, 'left', IMAGE_WIDTH+IMAGE_MARGIN_LEFT)
    @_addImages(parsedHilights)
  
  _addVerticalImages: (hilights, selectedHilights, offset, direction) ->
    parsedHilights = []
    for hilightName in selectedHilights
      hilight = hilights[hilightName]
      top = hilight.frame().top
      top -= (IMAGE_HEIGHT - hilight.frame().height)/2
      hilight.data('imagePosition', {left: offset, top: top})
      hilight.data('direction', direction)
      parsedHilights.push(hilight)
    @_shiftImages(parsedHilights, 'top', IMAGE_HEIGHT+IMAGE_MARGIN_TOP)
    @_addImages(parsedHilights)
  
  _shiftImages: (hilights, axis, size) ->
    hilights.sort (a, b) ->
      aPos = a.data('imagePosition')
      bPos = b.data('imagePosition')
      return -1 if aPos[axis] < bPos[axis]
      return 1 if aPos[axis] > bPos[axis]
      0
    last = _.first(hilights)
    for hilight, i in hilights
      continue if i == 0
      continue unless last
      lastImage = last.data('imagePosition')
      currentImage = hilight.data('imagePosition')
      overlap = currentImage[axis] - (lastImage[axis]+size)
      console.log overlap
      if overlap < 0
        half = Math.abs(overlap)/2
        lastImage[axis] -= half
        currentImage[axis] += half
        last.data('imagePosition', lastImage)
        hilight.data('imagePosition', currentImage)
      last = hilight
  
  _addImages: (hilights) ->
    for hilight in hilights
      direction = hilight.data('direction')
      position = hilight.data('imagePosition')
      @_addGlow(hilight, position.left, position.top, direction)
      @_addImage(position.left, position.top, direction)
  
  
  
  _addImage: (left, top, direction) ->
    item = $("<div />").addClass('image')
    image = $("<img />").addClass('thumbnail').attr('src', '/test.jpg').appendTo(item)
    item.css(left: left, top: top)
    props = {}
    distance = 75
    duration = 200
    delay = 100
    if direction == 'left'
      props.translateX = "#{distance}px"
    else if direction == 'right'
      props.translateX = "-#{distance}px"
    else if direction == 'top'
      props.translateY = "#{distance}px"
    else if direction == 'bottom'
      props.translateY = "-#{distance}px"
    props.opacity = 0
    props.scale = 0.5
    item.gfx(props, {duration: 1})
    @append item
    item.delay(@_imagesAdded * delay)
    item.gfx({opacity: 1, scale: 1, translateX: "0px", translateY: "0px"}, {duration: duration})
    @_imagesAdded += 1
  
  # Drawing glow
  # ---------------------------------------------------------------------------
  
  _addGlow: (hilight, left, top, direction) ->
    frame = hilight.frame()
    imageFrame = {left: left, top: top, width: IMAGE_WIDTH, height: IMAGE_HEIGHT}
    
    console.log direction
    if direction == 'top'
      topLeft = {x: imageFrame.left, y: imageFrame.top+IMAGE_HEIGHT}
      topRight = {x: imageFrame.left+IMAGE_WIDTH, y: imageFrame.top+IMAGE_HEIGHT}
      bottomLeft = {x: frame.left, y: frame.top}
      bottomRight = {x: frame.left+frame.width, y: frame.top}
    else if direction == 'bottom'
      topLeft = {x: imageFrame.left, y: imageFrame.top}
      topRight = {x: imageFrame.left+IMAGE_WIDTH, y: imageFrame.top}
      bottomLeft = {x: frame.left, y: frame.top+frame.height}
      bottomRight = {x: frame.left+frame.width, y: frame.top+frame.height}
    else if direction == 'left'
      topLeft = {x: imageFrame.left+IMAGE_WIDTH, y: imageFrame.top}
      topRight = {x: imageFrame.left+IMAGE_WIDTH, y: imageFrame.top+IMAGE_HEIGHT}
      bottomLeft = {x: frame.left, y: frame.top}
      bottomRight = {x: frame.left, y: frame.top+frame.height}
    else if direction == 'right'
      topLeft = {x: imageFrame.left, y: imageFrame.top}
      topRight = {x: imageFrame.left, y: imageFrame.top+IMAGE_HEIGHT}
      bottomLeft = {x: frame.left+frame.width, y: frame.top}
      bottomRight = {x: frame.left+frame.width, y: frame.top+frame.height}
    else
      return
    
    @context.beginPath();
    @context.moveTo(topLeft.x, topLeft.y);
    @context.lineTo(topRight.x, topRight.y);
    @context.lineTo(bottomRight.x, bottomRight.y);
    @context.lineTo(bottomLeft.x, bottomLeft.y);
    @context.closePath();
    @context.fill();
  
  # Distributing meawords to edges
  # ---------------------------------------------------------------------------
  
  _allEdges: (phrase, hilights) ->
    edges = {}
    phraseFrame = phrase.frame()
    for hilightName, hilight of hilights
      # Find the closest edge of it
      hilight = $(hilight)
      frame = hilight.frame()
      edges[hilightName] = @_edges(phraseFrame, frame)
    edges
  
  _balanceEdges: (edges) ->
    balancedEdges = {left: [], right: [], top: [], bottom: []}
    while !_.isEmpty(edges)
      for edge, items of balancedEdges
        hilightName = @_hilightForEdge(edges, edge)
        continue unless hilightName
        balancedEdges[edge].push(hilightName)
        delete edges[hilightName]
    balancedEdges
  
  _hilightForEdge: (hilightsByEdges, edge) ->
    for hilightName, edges of hilightsByEdges
      if _.include edges, edge
        return hilightName
    null
      
  _edges: (phraseFrame, frame) ->
    distance = @_edgeDistances(phraseFrame, frame)
    
    min_distance = distance.top
    for edge, dist of distance
      min_distance = dist if dist < min_distance
    
    edges = []
    for edge, dist of distance
      edges.push(edge) if dist == min_distance
    edges
  
  _edgeDistances: (phraseFrame, frame) ->
    distance =
      top: Math.abs(phraseFrame.top - frame.top)
      left: Math.abs(phraseFrame.left - frame.left)
      bottom: Math.abs((phraseFrame.top+phraseFrame.height) - (frame.top+frame.height))
      right: Math.abs((phraseFrame.left+phraseFrame.width) - (frame.left+frame.width))
    distance
  
  # Opening images
  # ---------------------------------------------------------------------------
  
  open: (e) ->
    image = $(e.currentTarget)
    if image.hasClass('open')
      @_close(image)
    else
      @_open(image)
  
  _open: (image) ->
    @_close(@_currentImage) if @_currentImage
    @_currentImage = image
    image.addClass('open')
    
    original = image.offset()
    image.data 'originalOffset', original
    
    width = IMAGE_WIDTH*4
    height = IMAGE_HEIGHT*4
    
    windowWidth = $(window).width()
    windowHeight = $(window).height()

    left = windowWidth/2 - (windowWidth-width)/2;
    top = windowHeight/2 - (windowHeight-height)/2;
    
    preview = new Preview(image: image, left: left, top: top, width: width, height: height)
    preview.didClose = @_close
    @append preview

    showPreview = -> preview.show()

    translateX = (left-original.left)/4
    translateY = (top-original.top)/4    
    image.gfx({scale: 4, translateX: "#{translateX}px", translateY: "#{translateY}px"}, {duration: 300, complete: showPreview, easing: 'linear'})
  
  _close: (image) =>
    @_currentImage = null
    image.removeClass('open')
    original = image.data('originalOffset')
    image.gfx({scale: 1, left: original.left, top: original.top}, {duration: 200})
    $(".preview").remove()

module.exports = App