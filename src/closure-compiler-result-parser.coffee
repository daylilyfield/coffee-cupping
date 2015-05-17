exports.parse = parse = (message) ->
  
  # drop out summary report
  [results..., _] = message.split /\n\n/
  
  results
    .map split /\n/
    .map toJson

split = (regex) -> (splittee) -> splittee.split regex

toJson = (lines) ->
  if /.* - assignment$/.test lines[0]
    toJsonAsAssignment lines

toJsonAsAssignment = (lines) ->
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
    \s([a-z]+) # type
    $
  ///
  [_, file, line, level, type] = regexp.exec general

  {file, line: parseInt(line), level, type}

