exports.Token = class Token

  constructor: (@type, @representation) ->

class Scanner

  constructor: (@expression) ->
    @rest = @expression
    @index = 0
 
  peek: ->
    @rest[0]
 
  take: ->
    [x, @rest...] = @rest
    @index += 1 if x?
    x

  hasNext: ->
    @index < @expression.length

k2v = (xs) ->
  xs.reduce (acc, x) ->
    acc[x] = x
    acc
  , {}

exports.TOKENS = TOKENS = k2v [
  'TYPE'
  'LPAREN'
  'RPAREN'
  'LBRACKET'
  'RBRACKET'
  'UNION'
  'LCURLY'
  'RCURLY'
  'FUNCTION'
  'NULLABLE'
  'NONNULLABLE'
  'OPTIONAL'
  'COMMA'
]

#: String, String -> [String]
range = (f, t) ->
  id = (f) -> (x) -> f x
  c = (x) -> x.charCodeAt(0)
  [(c f)..(c t)].map id String.fromCharCode

LETTERS =
  TYPE_FIRST: (range 'a', 'z').concat (range 'A', 'Z')
  TYPE: (range 'a', 'z').concat (range 'A', 'Z'), (range '0', '9')
  ARROW: '->'
  MINUS: '-'
  GT: '>'
  COMMA: ','

isTypeFirstLetter = (s) -> !!~LETTERS.TYPE_FIRST.indexOf s
isTypeLetter = (s) -> !!~LETTERS.TYPE.indexOf s
isMinus = (s) -> s is LETTERS.MINUS
isGt = (s) -> s is LETTERS.GT
isWhitespace = (s) -> s is ' '
isComma = (s) -> s is LETTERS.COMMA

exports.tokenize = (expression) ->
  scanner = new Scanner expression
  tokens = []

  while scanner.hasNext()
    c = scanner.take()
    token = switch
      when isTypeFirstLetter c then tokenType c, scanner
      when isMinus c then tokenFunction c, scanner
      when isWhitespace c then undefined # drop whitespace
      when isComma c then tokenComma c, scanner
      else throwError 'unknown token', scanner.index, scanner.expression

    tokens.push token if token?

  tokens

tokenComma = (c, scanner) -> new Token TOKENS.COMMA, c

tokenType = (c, scanner) ->
  r = [c]
  n = scanner.peek()
  while isTypeLetter n
    r.push scanner.take()
    n = scanner.peek()

  new Token TOKENS.TYPE, r.join ''

tokenFunction = (c, scanner) ->
  n = scanner.peek()
  if isGt n
    new Token TOKENS.FUNCTION, c + scanner.take()
  else
    throwError 'illegal token', scanner.index, scanner.expression

throwError = (message, position, expression) ->
  throw new Error """
    #{message}
    #{expression}
    #{whitespace position}^
  """

whitespace = (n) ->
  return '' if n <= 1
  (' ' for i in [1..n - 1]).join ''



