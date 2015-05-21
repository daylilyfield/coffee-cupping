{TOKENS} = require './lexer'

exports.Node = class Node

  constructor: ->

  toTypeExpression: ->
    throw new Error 'need to override'


exports.TypeNode = class TypeNode extends Node

  CONVERSIONS =
    'String': 'string'
    'Number': 'number'
    'Boolean': 'boolean'

  constructor: (@name) ->

  toTypeExpression: ->
    found = CONVERSIONS[@name]
    if found then found else @name


exports.ArgumentsNode = class ArgumentsNode extends Node

  constructor: (arg) ->
    @arguments = [arg]

  add: (arg) ->
    @arguments.push arg

exports.FunctionNode = class FunctionNode extends Node

  constructor: (@args, @return) ->

  toTypeExpression: ->
    args = @args.toTypeExpression()
    rtn = @return.toTypeExpression()
    "function(#{args}):#{rtn}"

exports.parse = parse = (tokens) ->
  stack = []

  while tokens.length > 0
    token = tokens.shift()
    switch
      when token.type is TOKENS.TYPE
        stack.push new TypeNode token.representation
      when token.type is TOKENS.FUNCTION
        node = stack.pop()
        stack.push new FunctionNode node, parse tokens

  stack.pop()


