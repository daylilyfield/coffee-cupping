HashMap = require 'hashmap'
{parser} = require 'coffee-script/lib/coffee-script/parser'
{Block, Comment, Assign, Value} = require 'coffee-script/lib/coffee-script/nodes'

typex = require './type-expression'

assignToTypeCommentMap = new HashMap()

module.exports = hack = () ->
  restoreComment = hackComment()
  resotreAssign = hackAssign()
  restoreParser = hackParser()
  restoreBlock = hackBlock()
  return ->
    restoreComment()
    resotreAssign()
    restoreParser()
    restoreBlock()

isTypeCommentNode = (node) -> /^::\s*.*/.test node.comment

trim = (x) -> x.trim()

hackBlock = ->
  original = Block::compileWithDeclarations
  Block::compileWithDeclarations = (o) ->
    fragments = original.call @, o
    vars = findDeclaredVariables fragments
    if vars?
      typedFragments = vars.map prefixTypeComment(o).bind @
      typedFragments.push @makeCode '\n'
      typedFragments = Array::concat.apply [], typedFragments
      fragments = replaceDeclaredVariables fragments, typedFragments
    fragments
  -> Block::compileWithDeclarations = original

replaceDeclaredVariables = (fragments, typedFragments) ->
  index = findDeclaredVariablesIndex fragments
  fragments.splice index, 3 # remove 'var '
  pre = fragments[0..(index - 1)]
  post = fragments[index..]
  results = Array::concat.apply pre, typedFragments
  results = Array::concat.apply results, post
  results

prefixTypeComment = (o) -> (variable) ->
  jsdoc = holder(o).types[variable]
  [
    @makeCode '\n'
    @makeCode jsdoc
    @makeCode '\n'
    @makeCode 'var '
    @makeCode variable
    @makeCode ';'
    @makeCode '\n'
  ]


findDeclaredVariablesIndex = (fragments) ->
  # we need to assign into variable to return single value.
  index = i for f, i in fragments when f.code is 'var '
  index

findDeclaredVariables = (fragments) ->
  index = findDeclaredVariablesIndex fragments
  if index?
    fragments[index + 1].code.split(',').map trim
  else
    null

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
      name = @variable.base.value
      # we may not produce CodeFragment because
      # BLOCK node is in charge of variable declaration.
      # so we do not make CodeFragment but law strings.
      holder(o).types[name] = jsdoc
    fragments
  -> Assign::compileNode = original

holder = (o) ->
  o.scope.__annotations ?= types: {}, consts: {}
  o.scope.__annotations
