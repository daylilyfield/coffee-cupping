parser = require '../src/closure-compiler-result-parser'

describe 'closure-compiler-result-parser', ->

  it 'can parse and report two errors', ->

    source = '''
      ./a.js:15: ERROR - assignment
      found   : number
      required: string
      v = 1;
      ^
      
      ./b.js:21: ERROR - assignment
      found   : string
      required: number
      i = 'value';
          ^
      
      2 error(s), 0 warning(s), 100.0% typed
    '''

    results = parser.parse source

    expect(results?.length) is 2
    expect(results[0].file) is './a.js'
    expect(results[0].line) is 15
    expect(results[0].level) is 'ERROR'
    expect(results[0].type) is 'assignment'
    expect(results[1].file) is './b.js'
    expect(results[1].line) is 21
    expect(results[1].level) is 'ERROR'
    expect(results[1].type) is 'assignment'

