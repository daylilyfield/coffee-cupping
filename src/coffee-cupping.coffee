fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

debug = require 'debug'
extend = require 'extend'
shell = require 'shelljs'
mkdirp = require 'mkdirp'
coffee = require 'coffee-script'
Promise = require 'bluebird'
{SourceMapConsumer} = require 'source-map'

hack = require './coffee-hack'
ccResultParser = require './closure-compiler-result-parser'

D = debug 'coffee-cupping'

CHECK_OK = 'OK'
WORK_DIR = './.coffee-cupping'
COMPILER_JAR = './node_modules/google-closure-compiler/compiler.jar'

withLog = (m, f) -> (args...) ->
  D "begin #{m}"
  r = f.apply null, args
  D "end #{m}"
  return r

exports.check = (p, option = {}) ->
  paths = if Array.isArray(p) then p else [p]

  option.compiler ?= COMPILER_JAR
  option.enc ?= 'utf8'
  option.workDir ?= WORK_DIR
  option.coffee ?= {}

  mkdirp option.workDir

  Promise
    .resolve paths
    .map relativePath
    .map read(option)
    .map heredocify
    .map compile(option)
    .map write(option)
    .then checkByClosure(option)
    .then parseCheckResult
    .catch console.log.bind console

relativePath = (p) -> path.relative process.cwd(), p

read = (option) -> (p) ->
  source = fs.readFileSync p, option.enc
  {path: p, source}

heredocify = (target) ->
  TYPE_COMMENT = /(\s*)#(::.*)(\s*)/g
  target.source = target.source.replace TYPE_COMMENT, '$1###$2 ###$3'
  target

compile = (option) -> (target) ->
  restore = hack()

  mandatory =
    generatedFile: "#{option.workDir}/#{target.path}.cupping.js"
    sourceFiles: [target.path]
    bare: true
    sourceMap: true

  {js, v3SourceMap} = coffee.compile target.source, extend(mandatory, option.coffee)
  restore()
  {js, v3SourceMap: JSON.parse v3SourceMap}

write = (option) -> ({js, v3SourceMap}) ->
  mkdirp path.dirname v3SourceMap.file
  fs.writeFileSync "#{v3SourceMap.file}", js
  v3SourceMap

checkByClosure = (option) -> (v3SourceMaps) ->
  jss = v3SourceMaps.reduce (acc, v3SourceMap) ->
    acc.concat '--js', v3SourceMap.file
  , []

  checks = [
    '--jscomp_error'
    'checkTypes'
  ]

  java = [
    'java'
    '-jar'
    option.compiler or COMPILER_JAR
  ]

  command = (java.concat checks, jss).join ' '
    
  new Promise (resolve, reject) ->
    exec command, (err, stdout, stderr) ->
      if err?.code > 1
        resolve {message: stderr, v3SourceMaps}
      else
        resolve {message: CHECK_OK, v3SourceMaps}

parseCheckResult = ({message, v3SourceMaps}) ->
  results = ccResultParser.parse message
  applySourceMapToResults results, v3SourceMaps

applySourceMapToResults = (results, v3SourceMaps) ->
  consumers = v3SourceMaps.reduce (acc, sm) ->
    c = new SourceMapConsumer sm
    acc[sm.file] = c
    acc
  , {}

  results.map (r) ->
    c = consumers[r.file]
    p = c.originalPositionFor
      line: r.line
      column: r.column + 1
    r.file = p.source
    r.line = p.line
    r.column = p.column
    r
    
