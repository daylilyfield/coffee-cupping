fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

extend = require 'extend'
shell = require 'shelljs'
mkdirp = require 'mkdirp'
coffee = require 'coffee-script'
Promise = require 'bluebird'

hack = require './coffee-hack'

CHECK_OK = 'OK'
WORK_DIR = './.coffee-cupping'
COMPILER_JAR = './node_modules/google-closure-compiler/compiler.jar'

class CoffeeFile

  #:: String, String -> Checktarget
  constructor: (path, coffee) ->
    #:: String
    @path = path
    #:: String
    @coffee = coffee

exports.check = (p, option = {}) ->
  paths = if Array.isArray(p) then source else [p]

  option.compiler or= COMPILER_JAR
  option.enc or= 'utf8'
  option.workDir or= WORK_DIR
  option.coffee or= {}

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

write = (option) -> (target) ->
  mkdirp path.dirname target.v3SourceMap.file
  fs.writeFileSync "#{target.v3SourceMap.file}", target.js
  target.v3SourceMap

#:: Object? -> Array[String] -> Promise
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
      if err?.code isnt 1
        reject stderr
      else if err?.code is 1
        resolve stderr
      else
        resolve CHECK_OK


parseCheckResult = (message) ->
  console.log message


