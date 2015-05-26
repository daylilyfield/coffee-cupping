cupping = require '../src/coffee-cupping'

length = (n) -> (rs) ->
  expect(rs.length).toBe n
  rs

match = (expected) -> (rs) ->
  expected.map (e, i) ->
    expect(e).toEqual rs[i]

ignore = (f) -> () -> f()

describe 'coffee-cupping', ->

  it 'should be errors because of variable type mismatch', (done) ->

    cupping
      .check "#{__dirname}/fixture/variable.coffee"
      .then length 2
      .then ignore done

  it 'should be an error because of function-call type mismatch', (done) ->

    cupping
      .check "#{__dirname}/fixture/function-call.coffee"
      .then length 3
      .then ignore done
