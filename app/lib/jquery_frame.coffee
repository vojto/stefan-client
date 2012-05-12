jQuery.fn.frame = ->
  frame = @offset()
  frame.width = @outerWidth()
  frame.height = @outerHeight()
  frame