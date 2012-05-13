Spine = require('spine')

class Docs extends Spine.Controller
  events:
    'tap .button': 'select'
  
  constructor: ->
    @el = $("#docs")
    super
    @el.hide()
  
  show: (docs) =>
    @docs = docs if docs
    for name, doc of docs
      option = $("<a />").addClass('option').addClass('button')
      option.text(name)
      @append option
    @el.show()
  
  hide: ->
    @el.hide()
  
  select: (e) =>
    dom = $(e.currentTarget)
    doc = @docs[dom.text()]
    @app.showFile(doc)

module.exports = Docs