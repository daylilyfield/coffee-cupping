doctrine = require 'doctrine'

CONTEXT_NONE = 'none'
CONTEXT_PARANTHESES = 'parantheses'

CONVERSIONS =
  'String': 'string'
  'Number': 'number'
  'Boolean': 'boolean'

exports.jsdocify = (expression) ->
  exp = expression.trim()
  if !~exp.search /->/
    jsdocifyAsType exp
  else
    jsdocifyAsFunction exp

jsdocifyAsFunction = (exp) ->
  index = 0
  char = exp.charAt index
  context = CONTEXT_NONE

  [consumed, result] = switch char
    when '(' then applyParentheses exp[index..]
    else applyType exp[index..]


#:: String -> String
jsdocifyAsType = (exp) ->
  """
    /**
     * @type {#{convert exp}}
     */
  """

convert = (type) -> CONVERSIONS[type] or type

_applyType = (fragment) ->
  [type] = /^[A-Z][a-zA-Z0-9.]*/.exec fragment
  consumed = type.length
  ast = title: 'param'
  consumed = type.length
  ast = doctrine.parse '''
    /**
     * @param {String|Number} hoge
     * @return {String}
     */
  ''', unwrap: true

  console.log ast

  ast.tags.map (e) ->
    console.log e
    console.log doctrine.type.stringify e.type

 

  #  description: ''
  #  tags: [
  #    title: 'param'
  #    description: ''
  #    name: 'hoge'
  #    type:
  #      type: 'NameExpression'
  #      name: String
  #  ]


applyParentheses = () ->
