require('lib/setup')
require('lib/jquery_frame')

text = require('./phrases')
Spine = require('spine')
_     = require('lib/underscore')

IMAGE_HEIGHT = 80
IMAGE_MARGIN_TOP = 10
IMAGE_MARGIN_LEFT = 10
IMAGE_WIDTH = 110

# TODO:
# - Deselecting phrase by tapping somewhere else

class App extends Spine.Controller
  events:
    'click .phrase': 'select'
    'touchstart .phrase': 'select'
  
  constructor: ->
    super
    
    text = text.replace /\.$/, ''
    phrases = text.split /\.\s*/
    
    for phrase in phrases
      phrase = phrase + ". "
      el = $("<span class='phrase' />").text(phrase)
      @append el
    
  select: (e) ->
    @_deselect()
    phrase = $(e.currentTarget)
    text = phrase.text()
    @_hilight(phrase)
    
    # 01 Find the meaning-words in the phrase
    # (This will be probably delegated to the server)
    
    # For now we're just gonna simulate this
    meawords = ["study", "night skies", "telescopes", "midnight", "planets"]
    # -----------------------------------------------------
    
    # 02 Hilight the meaning-words
    
    for meaword in meawords
      text = text.replace meaword, '<span class="hilight">' + meaword + '</span>'
    phrase.html(text)
    hilights = @_hilightsDict(phrase)
    
    # -----------------------------------------------------
    
    # 03 Show some images for each of the hilight/meaword
    @_images(phrase, hilights)    
    # -----------------------------------------------------
  
  _hilightsDict: (phrase) ->
    hilights = {}
    for hilight in phrase.find("span.hilight")
      hilight = $(hilight)
      hilights[hilight.text()] = hilight
    hilights
  
  _images: (phrase, hilights) ->
    # First we need to get some sort of bounds for the phrase
    phraseFrame = phrase.frame()
    $("#bounds").css(phraseFrame)

    edges = @_allEdges(phrase, hilights)
    balancedEdges = @_balanceEdges(edges)
    
    # console.log hilights
    # console.log balancedEdges

    topOffset = phraseFrame.top - (IMAGE_HEIGHT + IMAGE_MARGIN_TOP)
    @_addHorizontalImages(hilights, balancedEdges.top, topOffset)
    bottomOffset = (phraseFrame.top+phraseFrame.height) + IMAGE_MARGIN_TOP
    @_addHorizontalImages(hilights, balancedEdges.bottom, bottomOffset)
    leftOffset = phraseFrame.left - (IMAGE_WIDTH + IMAGE_MARGIN_LEFT)
    @_addVerticalImages(hilights, balancedEdges.left, leftOffset)
    rightOffset = (phraseFrame.left+phraseFrame.width) + IMAGE_MARGIN_LEFT
    @_addVerticalImages(hilights, balancedEdges.right, rightOffset)

  _addHorizontalImages: (hilights, selectedHilights, offset) ->
    for hilightName in selectedHilights
      hilight = hilights[hilightName]
      left = hilight.frame().left
      left -= (IMAGE_WIDTH - hilight.frame().width)/2
      @_addImage(left, offset)
  
  _addVerticalImages: (hilights, selectedHilights, offset) ->
    for hilightName in selectedHilights
      hilight = hilights[hilightName]
      top = hilight.frame().top
      top -= (IMAGE_HEIGHT - hilight.frame().height)/2
      @_addImage(offset, top)
    
  _addImage: (left, top) ->
    item = $("<div />").addClass('image')
    item.css(left: left, top: top)
    @append item
  
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

module.exports = App