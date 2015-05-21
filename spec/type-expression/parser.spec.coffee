lexer = require '../../src/type-expression/lexer'
parser = require '../../src/type-expression/parser'

describe 'type-expression/parser', ->

  it 'should make ast for variable type', ->

    source = 'String'

    ast = parser.parse lexer.tokenize source
    expect(ast.constructor.name).toBe parser.TypeNode.name

    expression = ast.toTypeExpression()
    expect(expression).toBe 'string'

  it 'should make ast for function type', ->

    source = 'Number -> String'

    ast = parser.parse lexer.tokenize source
    expect(ast.constructor.name).toBe parser.FunctionNode.name

    expression = ast.toTypeExpression()
    expect(expression).toBe 'function(number):string'
