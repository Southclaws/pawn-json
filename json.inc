// built-in include guard removal
// just in case the user has a local dependency with the same file name
#if defined _inc_json
	#undef _inc_json
#endif
// custom include-guard to ensure we don't duplicate
#if defined _json_included
	#endinput
#endif
#define _json_included

enum JSON_NODE {
    JSON_NODE_NUMBER,
    JSON_NODE_BOOLEAN,
    JSON_NODE_STRING,
    JSON_NODE_OBJECT,
    JSON_NODE_ARRAY,
    JSON_NODE_NULL,
}

// JSON_Parse decodes JSON and stores the root node into `output`.
native JSON_Parse(const string[], &Node:output);
native JSON_ParseFile(const path[], &Node:output);
native JSON_SaveFile(const path[], Node:input, bool:pretty = false);

// JSON_Stringify encodes a JSON node into `buf`.
native JSON_Stringify(Node:node, buf[], len = sizeof(buf));

// JSON_NodeType returns the type of a node from the above enumerator.
native JSON_NODE:JSON_NodeType(Node:node);

// JSON_Object allocates a node from a set of key-value pairs where each key must
// be a string and each value must be a `Node:` value. For example:
//
// JSON_Object("key", JSON_String("value"));
//
// output: {"key": "value"}
//
// Returns a `Node:` ID which can be passed as an argument to another JSON_Object
// function in order to build nested objects. For example:
//
// JSON_Object("key", JSON_Object("nestedKey", JSON_String("value")));
//
// output: {"key": {"nestedKey": "value"}}
//
native Node:JSON_Object({_, Node}:...);

// JSON_Int, JSON_Bool, JSON_Float, JSON_String each allocate a JSON node.
native Node:JSON_Int(value);
native Node:JSON_Bool(bool:value);
native Node:JSON_Float(Float:value);
native Node:JSON_String(const value[]);

// JSON_Array simply takes an argument list of `Node:` IDs.
//
// JSON_Array(JSON_String("value"), JSON_Int(1), JSON_Object("k", JSON_String("v")))
//
// output: ["value", 1, {"k": "v"}]
//
native Node:JSON_Array(Node:...);

// JSON_Append returns a new `Node:` which is the result of appending b to a.
// This works on both objects and arrays and the two input nodes will be deleted
// from the global node store. For example:
//
// new Node:a = JSON_Object("key1", JSON_String("value"));
// new Node:b = JSON_Object("key2", JSON_String("value"));
// new Node:c = JSON_Append(a, b);
//
// output: {"key1": "value", "key2": "value"}
//
// new Node:a = JSON_Array(JSON_Int(1), JSON_Int(2));
// new Node:a = JSON_Array(JSON_Int(3));
// new Node:c = JSON_Append(a, b);
//
// output: [1, 2, 3]
//
native Node:JSON_Append(Node:a, Node:b);
native Node:operator+(Node:a, Node:b) = JSON_Append;

// JSON_Remove removes any existing key from your node.
native JSON_Remove(Node:node, const key[]);

// JSON_RemoveNode removes `input` from array `node`
native JSON_RemoveNode(Node:node, Node:input);

// JSON_RemoveIndex removes the element at `index` from array `node`
native JSON_RemoveIndex(Node:node, index);

// JSON_Set* functions directly modify nodes by inserting or modifying keys.
native JSON_SetObject(Node:node, const key[], Node:object);
native JSON_SetArray(Node:node, const key[], Node:array);
native JSON_SetInt(Node:node, const key[], output);
native JSON_SetFloat(Node:node, const key[], Float:output);
native JSON_SetBool(Node:node, const key[], bool:output);
native JSON_SetString(Node:node, const key[], output[], len = sizeof(output));

// JSON_GetObject returns the `Node:` stored at `key` in the given `node`.
// For example:
//
// input: {"key": {"inner": 1}}
//
// new Node:output;
// JSON_GetObject(node, "key", output);
//
// `output` now contains a JSON object containing {"inner": 1}, this node can be
// treated like any other node:
//
// new outputValue;
// JSON_GetInt(output, outputValue);
// outputValue == 1
//
native JSON_GetObject(Node:node, const key[], &Node:output);

// JSON_Get* functions extract a native type from an object these functions are
// shorthand for:
//
// new Node:output;
// JSON_GetObject(node, "key", output);
// new string[128];
// JSON_GetNodeString(output, string);
//
// 99% of the time, you only need these functions to get values out of objects.
//
native JSON_GetInt(Node:node, const key[], &output);
native JSON_GetFloat(Node:node, const key[], &Float:output);
native JSON_GetBool(Node:node, const key[], &bool:output);
native JSON_GetString(Node:node, const key[], output[], len = sizeof(output));

// JSON_GetType returns the type of a node's key
native JSON_NODE:JSON_GetType(Node:node, const key[]);

// JSON_GetArray returns the `Node:` stored at `index` in the given `node`. The
// `Node:` returned could be an Object or a primitive, such as an int, float,
// bool or string. Use functions below to convert `Node:` into a native type.
// For example:
//
// input: {"key": [1, 2, 3]}
//
// new Node:output;
// JSON_GetArray(node, key, output);
//
// `output` now contains a JSON array and can be accessed with:
//
// new Node:element;
// JSON_ArrayObject(node, 1, element);
//
// `element` now contains a JSON integer type node and can be converted to a
// native integer type using `JSON_GetNodeInt`.
//
native JSON_GetArray(Node:node, const key[], &Node:output);
native JSON_ArrayLength(Node:node, &length);
native JSON_ArrayObject(Node:node, index, &Node:output);
native JSON_ArrayIterate(Node:node, &index, &Node:output);

// JSON_ArrayAppend appends any given node to an existing JSON array.
native JSON_ArrayAppend(Node:node, const key[], Node:input);

// JSON_ArrayRemove removes any given node from a JSON array if the node's data
// is found inside of it.
native JSON_ArrayRemove(Node:node, const key[], Node:input);

// JSON_ArrayRemoveIndex removes an item from a JSON array at the
// specified index. Note: the indexes are not persistent, so if you
// have a JSON array with 10 elements inside of it and remove index 3,
// 4-9 would be shuffled down respectively.
native JSON_ArrayRemoveIndex(Node:node, const key[], index);

// JSON_ArrayClear empties out all of the items in a JSON array.
native JSON_ArrayClear(Node:node, const key[]);

// JSON_Keys can be used to iterate through the keys inside of a JSON node
native JSON_Keys(Node:node, index, output[], len = sizeof(output));

// JSON_GetNode* functions extract a JSON object `Node:` to `output`.
// These are useful for when you get a `Node:` that represents a primitive type
// such as from JSON_GetArray.
native JSON_GetNodeInt(Node:node, &output);
native JSON_GetNodeFloat(Node:node, &Float:output);
native JSON_GetNodeBool(Node:node, &bool:output);
native JSON_GetNodeString(Node:node, output[], len = sizeof(output));

// JSON_ToggleGC toggles garbage collection for a node. This prevents
// `JSON_Cleanup` from deleting nodes if `auto` is true. In other words,
// disabling garbage collection for a node will prevent it from being deleted
// automatically when it leaves scope. This is useful for when you want to pass
// a node through function calls or store it for a longer period of time.
// Be very careful with this function as losing a node pointer will result in a
// classic memory leak. For example:
//
// new Node:n = JSON_Object();
// JSON_ToggleGC(n, false);
// CallLocalFunction("FillJSON_Object", "d", _:n);
// JSON_ToggleGC(n, true);
//
// This will ensure that each hook of `FillJSON_Object` does not delete `n` when
// it leaves scope.
//
native JSON_ToggleGC(Node:node, bool:toggle);

// -
// Internal
// -

// JSON_Cleanup is an internal function for cleaning up `Node:` objects. This is
// necessary because each of the object builder functions above allocate nodes
// in a pool to be passed between internal function calls. If called manually,
// leave `auto` as the default value of false which will ignore a garbage
// collection disable done with `JSON_ToggleGC`.
native JSON_Cleanup(Node:node, auto = false);

native JSON_CountNodes();

// cleans up nodes once they go out of scope.
stock operator~(const Node:nodes[], len) {
    for(new i; i < len; ++i) {
        JSON_Cleanup(nodes[i], true);
    }
}
