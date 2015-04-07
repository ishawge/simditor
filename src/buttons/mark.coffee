class MarkButton extends Button

  name: 'mark'

  icon: 'magic'

  htmlTag: 'mark'

  disableTag: 'pre, table'

  command: ->
    range = @editor.selection.getRange()
    return if range.collapsed

    nodes = @getRangeNode(range)

    marked = false

    nodes.forEach (ele) =>
      $ele = $(ele)
      if $ele.is 'mark'
        @editor.selection.save() unless marked
        $ele.replaceWith $ele.html()
        marked = true
      else if ele.nodeType is 3 and $ele.parent().is 'mark'
        $ele = $ele.parent()
        @editor.selection.save() unless marked
        $ele.replaceWith $ele.html()
        marked = true

    if marked
      @editor.selection.restore()
      @editor.trigger 'valuechanged'
      return

    document.execCommand 'hilitecolor', false, '#FFFF00'

    range = @editor.selection.getRange()
    nodes = @getRangeNode(range)

    @editor.selection.save()

    nodes.forEach (ele) ->
      $ele = $(ele)
      if $ele.is 'span[style]'
        $ele.replaceWith $('<mark>').html($ele.html())
      else if ele.nodeType is 3 and $ele.parent().is 'span[style]'
        $ele = $ele.parent()
        $ele.replaceWith $('<mark>').html($ele.html())

    @editor.selection.restore()

    @editor.trigger 'valuechanged'


  nextNode: (node) ->
    if node.hasChildNodes()
      return node.firstChild
    else
      while (node && !node.nextSibling)
          node = node.parentNode
      return null if !node
      return node.nextSibling

  getRangeNode: (range) ->
    node = range.startContainer
    endNode = range.endContainer
    return [node]  if node is endNode

    rangeNodes = []

    while (node and node isnt endNode)
      rangeNodes.push(node = @nextNode(node))

    node = range.startContainer

    while (node and node isnt range.commonAncestorContainer)
      rangeNodes.unshift(node)
      node = node.parentNode

    rangeNodes

Simditor.Toolbar.addButton MarkButton