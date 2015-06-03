[WIP] coffee-cupping
=======================

static typing with coffee-script powered by closure compiler.

coffee-cupping never add grammer extensions to perform static typing because it loves coffee-script syntax. instead, it uses **type comment** like below.

```coffeescript
#:: Number
i = 1
```

`#:: Number` is type comment. coffee-cupping handles these type of comment as type declaration. 

How to Install
--------------

WIP.

How to Use Command Line
-----------------------

if you have a file named 'a.coffee':

```coffeescript
#:: Number
i = 1

i = 'value'
```

and you can check the file by coffee-cupping command:

```bash
coffee-cupping a.coffee
```

and you get:

```
ERROR at a.coffee L4
found   : string
required: number

i = 'value'
^
```

How to Use API
-----------------

if you have a.coffee and b.coffee, you can use coffee-cupping API like below:

```coffeescript
cupping = require 'coffee-cupping'

promise = cupping.check ['a.coffee', 'b.coffee']
```

`promise` may resolve with an array of error information object.


How to Check CommonJS Module
-----------------------------

even if you make your code with commonjs module, you can use coffee-cupping to check your code.  you have two files named a.coffee and b.coffee.

a.coffee contains:

```coffee-script
#:: String
exports.x = 'x'

#:: Number, Number -> Number
exports.add = (x, y) -> x + y
```

and b.coffee contains:

```coffeescript
a = require './a'

a.x = 1

a.add 'x', 'y'
```

you can check these files by coffee-cupping command.

[WIP]

and you can also check by coffee-cupping API.

```coffeescript
cupping = require 'coffee-cupping'

option =
  commonjs:
    enable: true
    entry: 'b.coffee'

promise = cupping.check ['a.coffee', 'b.coffee'], option
```

Type Comment Format
-------------------

[WIP]

```coffeescript
#:: String
x = 'x'

#:: String -> Number
fx = (x) -> x.length

#:: (String | Number)
xi = 1

#:: [String]
xs = ['x', 's']

#:: {x: Number, y: Number}
p = x: 1, y: 1
```

Milestones
-----------

- [OK] check type for variable assignment
- [OK] check type for function call
- [OK] support the commonjs module dependency resolution
- [] check illegal assignment for const variable
- [] check nullable variable
- [] support class
- [] support class method
- [] support instance method
- [] support prototype inheritance
- [] support union type
- [] support type-constructor type like Array and Object
- [] support record type
- [] etc



