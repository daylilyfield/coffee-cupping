fs = require 'fs'

program = require 'commander'
glob = require 'glob'
Promise = require 'bluebird'

readFileAsync = Promise.promisify fs.readFile

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

format = (rs) ->
  if rs.length > 0
    ps = rs.map (r) ->
      readFileAsync(r.file, 'utf8').then (contents) -> """
        #{r.level} at #{r.file} L#{r.line}
        #{r.description}
        
        #{(contents.split '\n')[r.line - 1]}
        #{whitespace r.column}^
        
      """
    Promise.all ps

whitespace = (n) ->
  return '' if n is 0
  (' ' for i in [0..n - 1]).join ''


output = (rs) ->
  rs.map (r) ->
    console.log r

module.exports = main
