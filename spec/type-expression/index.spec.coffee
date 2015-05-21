typex = require '../../src/type-expression'

describe 'type-expresion', ->

  it 'should return @type', ->
    source = 'String'

    doc = typex.jsdocify source

    expect(doc).toBe '''
      /**
       * @type {string}
       */
    '''

