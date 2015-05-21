cupping = require '../src/coffee-cupping'

length = (n) -> (r) -> expect(r.length).toBe n

describe 'coffee-spec', ->

  it 'should be errors because of variable type mismatch', (done) ->

    cupping
      .check "#{__dirname}/fixture/variable.coffee"
      .then length 2
      .then done

  it 'should be an error because of type mismatch', (done) ->

    cupping
      .check "#{__dirname}/fixture/function-call.coffee"
      .then length 2
      .then done
