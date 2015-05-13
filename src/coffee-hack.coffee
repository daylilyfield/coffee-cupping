HashMap = require 'hashmap'
{parser} = require 'coffee-script/lib/coffee-script/parser'
{Comment, Assign} = require 'coffee-script/lib/coffee-script/nodes'

typex = require './type-expression'

assignToTypeCommentMap = new HashMap()

module.exports = hack = () ->
  restoreComment = hackComment()
  resotreAssign = hackAssign()
  restoreParser = hackParser()
  return ->
    restoreComment()
    resotreAssign()
    restoreParser()

isTypeCommentNode = (node) -> /^::\s*.*/.test node.comment

hackParser = ->
  original = parser.parse
  parser.parse = (tokens) ->
    nodes = original.call parser, tokens
    typeCommentNode = null
    nodes.traverseChildren no, (child) ->
      if child.constructor is Comment and isTypeCommentNode(child)
        typeCommentNode = child
      if typeCommentNode? and child.constructor is Assign
        assignToTypeCommentMap.set child, typeCommentNode
        typeCommentNode = null
      yes
  -> parser.parse = original

hackComment = ->
  original = Comment::compileNode
  Comment::compileNode = (o, level) ->
    if isTypeCommentNode @
      [@makeCode('')]
    else
      original.call @, o, level
  -> Comment::compileNode = original

hackAssign = ->
  original = Assign::compileNode
  Assign::compileNode = (o, level) ->
    fragments = original.call @, o, level
    comment = assignToTypeCommentMap.get @
    if comment?
      [_, expression] = comment.comment.match /^::\s*(.*)/
      jsdoc = typex.jsdocify expression
      [@makeCode('\n')
       @makeCode(jsdoc)
       @makeCode('\n')].concat fragments
    else
      fragments
  -> Assign::compileNode = original

