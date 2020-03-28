# pawn-json

[![GitHub](https://shields.southcla.ws/badge/sampctl-pawn--json-2f2f2f.svg?style=for-the-badge)](https://github.com/Southclaws/pawn-json)

This package provides an API for parsing from and serialising to JSON.

## Installation

Simply install to your project:

```bash
sampctl package install Southclaws/pawn-json
```

Include in your code and begin using the library:

```pawn
#include <json>
```

## Usage

If you don't already know what JSON is, a good place to start is
[MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON).
It's pretty much a web API standard nowadays (Twitter, Discord, GitHub and just
about every other API uses it to represent data). I'll briefly go over it before
getting into the API.

This plugin stores JSON values as "Nodes". Each node represents a value of one
type. Here are some examples of the representations of different node types:

- `{}` - Object that is empty
- `{"key": "value"}` - Object with one key that points to a String node
- `"hello"` - String
- `1` - Number (integer)
- `1.5` - Number (floating point)
- `[1, 2, 3]` - Array, of Number nodes
- `[{}, {}]` - Array of empty Object nodes
- `true` - Boolean

The main point here is that everything is a node, even Objects and Arrays that
contain other nodes.

### Building an Object

To build a JSON object, you most likely want to start with `JSON_Object` however
you can use any node as the root node, it depends on where you're sending the
data but for this example I'll use an Object as the root node.

```pawn
new Node:node = JSON_Object();
```

This just constructs an empty object and if you "stringify" it (stringify simply
means to turn into a string) you get:

```json
{}
```

So to add more nodes to this object, simply add parameters, as key-value pairs:

```pawn
new Node:node = JSON_Object(
    "key", JSON_String("value")
);
```

This would stringify as:

```json
{
  "key": "value"
}
```

You can nest objects within objects too:

```pawn
new Node:node = JSON_Object(
    "key", JSON_Object(
        "key", JSON_String("value")
    )
);
```

```json
{
  "key": {
    "key": "value"
  }
}
```

And do arrays of any node:

```pawn
new Node:node = JSON_Object(
    "key", JSON_Array(
        JSON_String("one"),
        JSON_String("two"),
        JSON_String("three"),
        JSON_Object(
            "more_stuff1", JSON_String("uno"),
            "more_stuff2", JSON_String("dos"),
            "more_stuff3", JSON_String("tres")
        )
    )
);
```

See the
[unit tests](https://github.com/Southclaws/pawn-json/blob/master/test.pwn)
for more examples of JSON builders.

#### Accessing Data

When you get JSON data, it's provided as a `Node:` in the callback. Most of
the time, you'll get an object back but depending on the application that
responded this could differ.

Lets assume you have the following data:

```json
{
  "name": "Southclaws",
  "score": 45,
  "vip": true,
  "inventory": [
    {
      "name": "M4",
      "ammo": 341
    },
    {
      "name": "Desert Eagle",
      "ammo": 32
    }
  ]
}
```

```pawn
public OnSomeResponse(Node:json) {
    new ret;

    new name[MAX_PLAYER_NAME];
    ret = JSON_GetString(node, "name", name);
    if(ret) {
        err("failed to get name, error: %d", ret);
        return 1;
    }

    new score;
    ret = JSON_GetInt(node, "score", score);
    if(ret) {
        err("failed to get score, error: %d", ret);
        return 1;
    }

    new bool:vip;
    ret = JSON_GetBool(node, "vip", vip);
    if(ret) {
        err("failed to get vip, error: %d", ret);
        return 1;
    }

    new Node:inventory;
    ret = JSON_GetArray(node, "inventory", inventory);
    if(ret) {
        err("failed to get inventory, error: %d", ret);
        return 1;
    }

    new length;
    ret = JSON_ArrayLength(inventory, length);
    if(ret) {
        err("failed to get inventory array length, error: %d", ret);
        return 1;
    }

    for(new i; i < length; ++i) {
        new Node:item;
        ret = JSON_ArrayObject(inventory, i, item);
        if(ret) {
            err("failed to get inventory item %d, error: %d", i, ret);
            return 1;
        }

        new itemName[32];
        ret = JSON_GetString(item, "name", itemName);
        if(ret) {
            err("failed to get inventory item %d, error: %d", i, ret);
            return 1;
        }

        new itemAmmo;
        ret = JSON_GetInt(item, "name", itemAmmo);
        if(ret) {
            err("failed to get inventory item %d, error: %d", i, ret);
            return 1;
        }

        printf("item %d name: %s ammo: %d", itemName, itemAmmo);
    }

    return 0;
}
```

In this example, we extract each field from the JSON object with full error
checking. This example shows usage of object and array access as well as
primitives such as strings, integers and a boolean.

If you're not a fan of the overly terse and explicit error checking, you can
alternatively just check your errors at the end but this will mean you won't
know exactly _where_ an error occurred, just that it did.

```pawn
new ret;
ret += JSON_GetString(node, "key1", value1);
ret += JSON_GetString(node, "key2", value2);
ret += JSON_GetString(node, "key3", value3);
if(ret) {
    err("some error occurred: %d", ret);
}
```
