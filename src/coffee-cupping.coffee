fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

d = do require './util/debug'
extend = require 'extend'
shell = require 'shelljs'
mkdirp = require 'mkdirp'
coffee = require 'coffee-script'
Promise = require 'bluebird'
{SourceMapConsumer} = require 'source-map'

hack = require './coffee-hack'
ccResultParser = require './closure-compiler-result-parser'

CHECK_OK = 'OK'
WORK_DIR = './.coffee-cupping'
COMPILER_JAR = './node_modules/google-closure-compiler/compiler.jar'

exports.check = (p, option = {}) ->
  paths = if Array.isArray(p) then p else [p]

  option.compiler ?= COMPILER_JAR
  option.enc ?= 'utf8'
  option.workDir ?= WORK_DIR
  option.coffee ?= {}
  option.commonjs ?= enable: false, entry: ''

  d 'check option: ', option

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

relativePath = (p) -> path.relative process.cwd(), p

read = (option) -> (p) ->
  d 'read coffee file from:', p
  source = fs.readFileSync p, option.enc
  {path: p, source}

heredocify = (target) ->
  TYPE_COMMENT = /(\s*)#(::.*)(\s*)/g
  target.source = target.source.replace TYPE_COMMENT, '$1###$2 ###$3'
  target

compile = (option) -> (target) ->
  d 'compile coffee file:' ,target.path
  restore = hack()

  mandatory =
    generatedFile: "#{option.workDir}/#{target.path.slice 0, -7}.js"
    sourceFiles: [target.path]
    bare: true
    sourceMap: true

  {js, v3SourceMap} = coffee.compile target.source, extend(mandatory, option.coffee)
  restore()
  {js, v3SourceMap: JSON.parse v3SourceMap}


write = (option) -> ({js, v3SourceMap}) ->
  d 'write js file into: %s', v3SourceMap.file
  mkdirp path.dirname v3SourceMap.file
  fs.writeFileSync "#{v3SourceMap.file}", js
  v3SourceMap

checkByClosure = (option) -> (v3SourceMaps) ->
  jss = makeClosureJsOption v3SourceMaps
  checks = makeClosureCheckOption option
  commonjs = makeClosureCommonJsOption option, v3SourceMaps

  java = [
    'java'
    '-jar'
    option.compiler
  ]

  command = (java.concat checks, commonjs, jss).join ' '

  d 'run cc: %s', command
    
  new Promise (resolve, reject) ->
    exec command, (err, stdout, stderr) ->
      if err?.code > 1
        resolve {message: stderr, v3SourceMaps}
      else
        resolve {message: CHECK_OK, v3SourceMaps}

makeClosureJsOption = (v3SourceMaps) ->
  v3SourceMaps.reduce (acc, v3SourceMap) ->
    acc.concat '--js', v3SourceMap.file
  , []

makeClosureCheckOption = (option) -> [
  '--jscomp_error'
  'checkTypes'
]

makeClosureCommonJsOption = (option, v3SourceMaps) ->
  if option.commonjs.enable
    entry = relativePath option.commonjs.entry
    js = sm.file for sm in v3SourceMaps when sm.sources[0] is entry
    ['--process_common_js_modules', '--common_js_entry_module', js]
  else
    []

parseCheckResult = ({message, v3SourceMaps}) ->
  d 'cc results: %s', message
  results = ccResultParser.parse message
  d 'parsed cc results: %o', results
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
    
