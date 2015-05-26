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
    @args = [arg]

  add: (arg) ->
    @args.push arg

  toTypeExpression: ->
    (@args.map (a) -> a.toTypeExpression()).join ','

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
        node = stack.pop()
        if node?.constructor is ArgumentsNode
          node.add new TypeNode token.representation
          stack.push node
        else
          stack.push new TypeNode token.representation
      when token.type is TOKENS.FUNCTION
        node = stack.pop()
        stack.push new FunctionNode node, parse tokens
      when token.type is TOKENS.COMMA
        node = stack.pop()
        stack.push new ArgumentsNode node
      else
        throw new Error "unknown token: #{token}"

  stack.pop()


