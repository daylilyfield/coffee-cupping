[WIP] coffee-cupping
=======================

static typing with coffee-script.

Install
-------

TODO

How to Use
-----------

because coffee-cupping loves coffee-script syntax, it never add grammer extensions to perform static typing. instead, it uses **type comment** like below.

```coffeescript
#:: Number
i = 1
```

`#:: Number` is type comment. coffee-cupping handles these type of comment as type declaration. so, if you have a file named 'a.coffee':

```coffeescript
#:: Number
i = 1

i = 'value'
```

and you check that file by coffee-cupping, you get:

```json
[
  { "file": "a.coffee",
    "line": 4,
    "level": "ERROR",
    "type": "assignment",
    "description": "found   : string\nrequired: number",
    "column": 0 }
]
```

(wip! sorry terrible output! just a json!)

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



