exports.parse = parse = (message) ->
  
  # drop out summary report
  [results..., _] = message.split /\n\n/
  
  results
    .map split /\n/
    .map toJson
    .filter (x) -> x?

split = (regex) -> (splittee) -> splittee.split regex

toJson = (lines) ->
  switch
    when /.* - assignment$/.test lines[0]
      toJsonAsAssignment lines
    when /.* does not match formal parameter$/.test lines[0]
      toJsonFormalParameter lines
    else
      undefined

toJsonAsAssignment = toJsonFormalParameter = (lines) ->
  [general, descriptions..., fragment, mark] = lines
  result = parseGeneral general
  result.description = descriptions.join '\n'
  result.column = detectColumnPosition mark
  result

detectColumnPosition = (mark) ->
  [_, blanks] = /^(\s*)\^*/.exec mark or []
  if blanks? then blanks.length else 0

parseGeneral = (general) ->
  # ex: foo.js:15: ERROR - assignment
  regexp = ///
    ^
    ([^:]+) # file name
    :
    ([0-9]+) # line number
    :
    \s(ERROR|WARNING)\s # level
    -
    \s([a-zA-Z0-9\s\?\.\,]+) # type
    $
  ///
  [_, file, line, level, type] = regexp.exec general

  {file, line: parseInt(line), level, type}

