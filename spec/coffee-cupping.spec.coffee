cupping = require '../src/coffee-cupping'

length = (n) -> (r) -> expect(r.errors.length).toBe n

describe 'coffee-spec', ->

  it 'should be an error because of variable type mismatch', (done) ->

    cupping
      .check "#{__dirname}/fixture/variable.coffee"
      .then length 1
      .then done

  #it 'should be an error because of type mismatch', (done) ->

  #  source = '''
  #    #:: String -> String
  #    f = (x) -> x
  #    f 1
  #  '''

  #  cupping
  #    .check source
  #    .then (r) -> expect(r.errors.length).toBe 1
  #    .then done

  #it 'should be an error even if expression is multi line', (done) ->
  #  done()
