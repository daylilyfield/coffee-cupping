program = require 'commander'
glob = require 'glob'
Promise = require 'bluebird'

globAsync = Promise.promisify glob

cupping = require './coffee-cupping'

main = ->
  program
    .version '0.0.0'
    .usage '[option] <files...>'
    #.option '-f, --format <format>', 'output format', 'format'
    #.option '-o, --output <output>', 'output location', 'output'
    #.option '-e, --error-rule <rule>', 'rule handled as error'
    #.option '-w, --warning-rule <rule>', 'rule handled as warning'
    .parse process.argv

  files = program.args
  option = {} #TODO parse option

  Promise
    .all files.map (file) -> globAsync file
    .reduce (l, r) -> Array::concat l, r; l
    .then check option

check = (option) -> (files) ->
  cupping
    .check files, option
    .then format
    .then output

format = (rs) -> rs

output = (rs) -> console.log rs

module.exports = main
