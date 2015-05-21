lexer = require './lexer'
parser = require './parser'

exports.jsdocify = (expression) ->
  tokens = lexer.tokenize expression.trim()
  ast = parser.parse tokens
  typeExpression = ast.toTypeExpression()

  """
    /**
     * @type {#{typeExpression}}
     */
  """
