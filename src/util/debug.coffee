debug = require 'debug'

module.exports = (namespace) ->
  n = if namespace? then ":#{namespace}" else ''
  debug "coffee-cupping#{n}"



