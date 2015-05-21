lexer = require '../../src/type-expression/lexer'

describe 'lexer', ->

  it 'should tokenize variable type expression', ->

    expression = 'String'

    tokens = lexer.tokenize expression

    expect(tokens.length).toBe 1
    expect(tokens[0].type).toBe lexer.TOKENS.TYPE
    expect(tokens[0].representation).toBe 'String'

  it 'should tokenize function type expression', ->

    expression = 'Number -> String'

    tokens = lexer.tokenize expression

    expect(tokens.length).toBe 3
    expect(tokens[0].type).toBe lexer.TOKENS.TYPE
    expect(tokens[0].representation).toBe 'Number'
    expect(tokens[1].type).toBe lexer.TOKENS.FUNCTION
    expect(tokens[1].representation).toBe '->'
    expect(tokens[2].type).toBe lexer.TOKENS.TYPE
    expect(tokens[2].representation).toBe 'String'
    
