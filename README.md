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

WIP.

Type Comment Format
-------------------

WIP.

```coffeescript
#:: String
x = 'x'

#:: String -> Number
fx = (x) -> x.length

#:: String | Number
xi = 1

#:: [String]
xs = ['x', 's']

#:: {x: Number, y: Number}
p = x: 1, y: 1
```

Milestones
-----------

- [OK] check type for variable assignment
- [] check type for function assignment
- [OK] check type for function call
- [] check illegal assignment for const variable
- [] check nullable variable
- [] support union type
- [] support type-constructor type like Array
- [] support record type
- [] etc



