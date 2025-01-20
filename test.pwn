#define RUN_TESTS

#include <a_samp>
#include <YSI_Core\y_testing>

#include "json.inc"

main() {
    SetTimer("timeout", 10000, false);
}

forward timeout();
public timeout() {
    SendRconCommand("exit");
}

Test:JsonParse() {
    new Node:node;
    new ret;

    new input[] = "{\"list\":[{\"a_listobj_float\":66.5999984741211,\"a_listobj_number\":76,\"a_listobj_string\":\"another value\",\"one\":\"value one\"},{\"a_listobj_float\":66.5999984741211,\"a_listobj_number\":76,\"a_listobj_string\":\"another value\",\"two\":\"value two\"},{\"a_listobj_float\":66.5999984741211,\"a_listobj_number\":76,\"a_listobj_string\":\"another value\",\"three\":\"value three\"}],\"object\":{\"a_float\":66.5999984741211,\"a_number\":76,\"a_string\":\"a value\",\"nested_object\":{\"a_deeper_float\":66.5999984741211,\"a_deeper_number\":76,\"a_deeper_string\":\"another value\"}}}";

    ret = JSON_Parse(input, node);
    ASSERT_EQ(ret, 0);

    new output[1024];
    ret = JSON_Stringify(node, output);
    ASSERT(!strcmp(input, output));
}

Test:JsonNodeType() {
    new Node:number = JSON_Int(3); // JSON_NODE_NUMBER
    ASSERT(JSON_NodeType(number) ==  JSON_NODE_NUMBER);

    new Node:boolean = JSON_Bool(true); // JSON_NODE_BOOLEAN
    ASSERT(JSON_NodeType(boolean) ==  JSON_NODE_BOOLEAN);

    new Node:string = JSON_String("hi"); // JSON_NODE_STRING
    ASSERT(JSON_NodeType(string) ==  JSON_NODE_STRING);

    new Node:object = JSON_Object("k", JSON_Int(1)); // JSON_NODE_OBJECT
    ASSERT(JSON_NodeType(object) ==  JSON_NODE_OBJECT);

    new Node:array = JSON_Array(JSON_Int(1), JSON_Int(2)); // JSON_NODE_ARRAY
    ASSERT(JSON_NodeType(array) ==  JSON_NODE_ARRAY);

    new Node:null = Node:-1; // JSON_NODE_NULL
    ASSERT(JSON_NodeType(null) ==  JSON_NODE_NULL);
}

Test:JSON_ObjectEmpty() {
    new Node:node = JSON_Object();

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{}"));
}

Test:JSON_ObjectInt() {
    new Node:node = JSON_Object(
        "key", JSON_Int(1)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":1}"));
    print(buf);
}

Test:JSON_ObjectInts() {
    new Node:node = JSON_Object(
        "key1", JSON_Int(1),
        "key2", JSON_Int(2),
        "key3", JSON_Int(3)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key1\":1,\"key2\":2,\"key3\":3}"));
    print(buf);
}

Test:JSON_ObjectFloat() {
    new Node:node = JSON_Object(
        "key", JSON_Float(1.5)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":1.5}"));
    print(buf);
}

Test:JSON_ObjectFloats() {
    new Node:node = JSON_Object(
        "key1", JSON_Float(1.5),
        "key2", JSON_Float(2.5),
        "key3", JSON_Float(3.5)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key1\":1.5,\"key2\":2.5,\"key3\":3.5}"));
    print(buf);
}

Test:JSON_ObjectBool() {
    new Node:node = JSON_Object(
        "key", JSON_Bool(true)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":true}"));
    print(buf);
}

Test:JSON_ObjectBools() {
    new Node:node = JSON_Object(
        "key1", JSON_Bool(false),
        "key2", JSON_Bool(true),
        "key3", JSON_Bool(false)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key1\":false,\"key2\":true,\"key3\":false}"));
    print(buf);
}

Test:JSON_ObjectString() {
    new Node:node = JSON_Object(
        "key", JSON_String("value")
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":\"value\"}"));
    print(buf);
}

Test:JSON_ObjectStrings() {
    new Node:node = JSON_Object(
        "key1", JSON_String("value1"),
        "key2", JSON_String("value2"),
        "key3", JSON_String("value3")
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key1\":\"value1\",\"key2\":\"value2\",\"key3\":\"value3\"}"));
    print(buf);
}

Test:JSON_StringArray() {
    new Node:node = JSON_Array(
        JSON_String("one"),
        JSON_String("two"),
        JSON_String("three")
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "[\"one\",\"two\",\"three\"]"));
    print(buf);
}

Test:JSON_IntArray() {
    new Node:node = JSON_Array(
        JSON_Int(1),
        JSON_Int(2),
        JSON_Int(3)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "[1,2,3]"));
    print(buf);
}

Test:JSON_FloatArray() {
    new Node:node = JSON_Array(
        JSON_Float(1.5),
        JSON_Float(2.5),
        JSON_Float(3.5)
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "[1.5,2.5,3.5]"));
    print(buf);
}

Test:JSON_ObjectArray() {
    new Node:node = JSON_Array(
        JSON_Object(
            "one", JSON_String("value one")
        ),
        JSON_Object(
            "two", JSON_String("value two")
        ),
        JSON_Object(
            "three", JSON_String("value three")
        )
    );

    new buf[128];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "[{\"one\":\"value one\"},{\"two\":\"value two\"},{\"three\":\"value three\"}]"));
    print(buf);
}

/*
JSON_ObjectComplex generates this rather complex JSON object:
{
  "object": {
    "a_float": 66.599998474121094,
    "a_number": 76,
    "a_string": "a value",
    "nested_object": {
      "a_deeper_float": 66.599998474121094,
      "a_deeper_number": 76,
      "a_deeper_string": "another value"
    }
  },
  "list": [
    {
      "a_listobj_float": 66.599998474121094,
      "a_listobj_number": 76,
      "a_listobj_string": "another value",
      "one": "value one"
    },
    {
      "a_listobj_float": 66.599998474121094,
      "a_listobj_number": 76,
      "a_listobj_string": "another value",
      "two": "value two"
    },
    {
      "a_listobj_float": 66.599998474121094,
      "a_listobj_number": 76,
      "a_listobj_string": "another value",
      "three": "value three"
    }
  ]
}
*/
Test:JSON_ObjectComplex() {
    new Node:node = JSON_Object(
        "object", JSON_Object(
            "a_string", JSON_String("a value"),
            "a_number", JSON_Int(76),
            "a_float", JSON_Float(66.6),
            "nested_object", JSON_Object(
                "a_deeper_string", JSON_String("another value"),
                "a_deeper_number", JSON_Int(76),
                "a_deeper_float", JSON_Float(66.6)
            )
        ),
        "list", JSON_Array(
            JSON_Object(
                "one", JSON_String("value one"),
                "a_listobj_string", JSON_String("another value"),
                "a_listobj_number", JSON_Int(76),
                "a_listobj_float", JSON_Float(66.6)
            ),
            JSON_Object(
                "two", JSON_String("value two"),
                "a_listobj_string", JSON_String("another value"),
                "a_listobj_number", JSON_Int(76),
                "a_listobj_float", JSON_Float(66.6)
            ),
            JSON_Object(
                "three", JSON_String("value three"),
                "a_listobj_string", JSON_String("another value"),
                "a_listobj_number", JSON_Int(76),
                "a_listobj_float", JSON_Float(66.6)
            )
        )
    );

    new buf[1024];
    new ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"list\":[{\"a_listobj_float\":66.5999984741211,\"a_listobj_number\":76,\"a_listobj_string\":\"another value\",\"one\":\"value one\"},{\"a_listobj_float\":66.5999984741211,\"a_listobj_number\":76,\"a_listobj_string\":\"another value\",\"two\":\"value two\"},{\"a_listobj_float\":66.5999984741211,\"a_listobj_number\":76,\"a_listobj_string\":\"another value\",\"three\":\"value three\"}],\"object\":{\"a_float\":66.5999984741211,\"a_number\":76,\"a_string\":\"a value\",\"nested_object\":{\"a_deeper_float\":66.5999984741211,\"a_deeper_number\":76,\"a_deeper_string\":\"another value\"}}}"));
    print(buf);
}

Test:JsonAppendObject() {
    new Node:a = JSON_Object(
        "key1", JSON_String("value1"),
        "key2", JSON_String("value2")
    );
    new Node:b = JSON_Object(
        "key3", JSON_String("value3")
    );

    new Node:c = JSON_Append(a, b);

    new buf[128];
    new ret = JSON_Stringify(c, buf);
    ASSERT_EQ(ret, 0);
    ASSERT_SAME(buf, "{\"key1\":\"value1\",\"key2\":\"value2\",\"key3\":\"value3\"}");
    print(buf);
}

Test:JsonAppendArray() {
    new Node:a = JSON_Array(
        JSON_Int(1),
        JSON_Int(2)
    );
    new Node:b = JSON_Array(
        JSON_Int(3)
    );

    new Node:c = JSON_Append(a, b);

    new buf[128];
    new ret = JSON_Stringify(c, buf);
    ASSERT_EQ(ret, 0);
    ASSERT_SAME(buf, "[1,2,3]");
    print(buf);
}

Test:JsonSetObject() {
    new Node:node = JSON_Object();
    new ret = JSON_SetObject(node, "key", JSON_Object("key", JSON_String("value")));
    ASSERT(ret == 0);

    new buf[128];
    ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":{\"key\":\"value\"}}"));
    print(buf);
}

Test:JsonSetArray() {
    new Node:node = JSON_Object();
    new ret = JSON_SetArray(node, "key", JSON_Array(JSON_Int(1), JSON_Int(2)));
    ASSERT(ret == 0);

    new buf[128];
    ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":[1,2]}"));
}

Test:JsonSetInt() {
    new Node:node = JSON_Object();
    new ret = JSON_SetInt(node, "key", 5);
    ASSERT(ret == 0);

    new buf[128];
    ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":5}"));
    print(buf);
}

Test:JsonSetFloat() {
    new Node:node = JSON_Object();
    new ret = JSON_SetFloat(node, "key", 5.5);
    ASSERT(ret == 0);

    new buf[128];
    ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":5.5}"));
    print(buf);
}

Test:JsonSetBool() {
    new Node:node = JSON_Object();
    new ret = JSON_SetBool(node, "key", true);
    ASSERT(ret == 0);

    new buf[128];
    ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":true}"));
    print(buf);
}

Test:JsonSetString() {
    new Node:node = JSON_Object();
    new ret = JSON_SetString(node, "key", "value");
    ASSERT(ret == 0);

    new buf[128];
    ret = JSON_Stringify(node, buf);
    ASSERT(ret == 0);
    ASSERT(!strcmp(buf, "{\"key\":\"value\"}"));
    print(buf);
}

Test:JsonGetInt() {
    new Node:node = JSON_Object(
        "key1", JSON_Int(1),
        "key2", JSON_Int(2),
        "key3", JSON_Int(3)
    );

    new got;
    new ret;
    
    ret = JSON_GetInt(node, "key1", got);
    ASSERT_EQ(ret, 0);
    ASSERT_EQ(got, 1);

    ret = JSON_GetInt(node, "key2", got);
    ASSERT_EQ(ret, 0);
    ASSERT_EQ(got, 2);

    ret = JSON_GetInt(node, "key3", got);
    ASSERT_EQ(ret, 0);
    ASSERT_EQ(got, 3);

    ret = JSON_GetInt(node, "key4", got);
    ASSERT_EQ(ret, 2);
}

Test:JsonGetFloat() {
    new Node:node = JSON_Object(
        "key1", JSON_Float(1.5),
        "key2", JSON_Float(2.5),
        "key3", JSON_Float(3.5)
    );

    new Float:got;
    new ret;
    
    ret = JSON_GetFloat(node, "key1", got);
    ASSERT(ret == 0);
    ASSERT(got == 1.5);

    ret = JSON_GetFloat(node, "key2", got);
    ASSERT(ret == 0);
    ASSERT(got == 2.5);

    ret = JSON_GetFloat(node, "key3", got);
    ASSERT(ret == 0);
    ASSERT(got == 3.5);

    ret = JSON_GetFloat(node, "key4", got);
    ASSERT(ret == 2);
}

Test:JsonGetBool() {
    new Node:node = JSON_Object(
        "key1", JSON_Bool(false),
        "key2", JSON_Bool(true),
        "key3", JSON_Bool(false)
    );

    new bool:got;
    new ret;
    
    ret = JSON_GetBool(node, "key1", got);
    ASSERT(ret == 0);
    ASSERT(got == false);

    ret = JSON_GetBool(node, "key2", got);
    ASSERT(ret == 0);
    ASSERT(got == true);

    ret = JSON_GetBool(node, "key3", got);
    ASSERT(ret == 0);
    ASSERT(got == false);

    ret = JSON_GetBool(node, "key4", got);
    ASSERT(ret == 2);
}

Test:JsonGetString() {
    new Node:node = JSON_Object(
        "key1", JSON_String("value1"),
        "key2", JSON_String("value2"),
        "key3", JSON_String("value3")
    );

    new got[128];
    new ret;
    
    ret = JSON_GetString(node, "key1", got);
    ASSERT(ret == 0);
    ASSERT(!strcmp(got, "value1"));

    ret = JSON_GetString(node, "key2", got);
    ASSERT(ret == 0);
    ASSERT(!strcmp(got, "value2"));

    ret = JSON_GetString(node, "key3", got);
    ASSERT(ret == 0);
    ASSERT(!strcmp(got, "value3"));

    ret = JSON_GetString(node, "key4", got);
    ASSERT(ret == 2);
}

Test:JsonGetArray() {
    new Node:node = JSON_Object(
        "key1", JSON_Array(
            JSON_String("one"),
            JSON_String("two"),
            JSON_String("three")
        )
    );

    new Node:arrayNode;
    new ret;

    ret = JSON_GetArray(node, "key1", arrayNode);
    printf("JSON_GetArray:%d arrayNode: %d", ret, _:arrayNode);
    ASSERT_EQ(ret, 0);

    new Node:output;
    new gotString[32];

    ret = JSON_ArrayObject(arrayNode, 0, output);
    ASSERT_EQ(ret, 0);
    ret = JSON_GetNodeString(output, gotString);
    ASSERT_EQ(ret, 0);
    ASSERT_SAME(gotString, "one");

    ret = JSON_ArrayObject(arrayNode, 1, output);
    ASSERT_EQ(ret, 0);
    ret = JSON_GetNodeString(output, gotString);
    ASSERT_EQ(ret, 0);
    ASSERT_SAME(gotString, "two");

    ret = JSON_ArrayObject(arrayNode, 2, output);
    ASSERT_EQ(ret, 0);
    ret = JSON_GetNodeString(output, gotString);
    ASSERT_EQ(ret, 0);
    ASSERT_SAME(gotString, "three");
}

Test:JsonGetIntInvalid() {
    new Node:node = JSON_Object("k", JSON_String("v"));
    new gotInt;
    new ret = JSON_GetInt(node, "key4", gotInt);
    ASSERT(ret == 2);
}

Test:JsonGetFloatInvalid() {
    new Node:node = JSON_Object("k", JSON_String("v"));
    new Float:gotFloat;
    new ret = JSON_GetFloat(node, "key4", gotFloat);
    ASSERT(ret == 2);
}

Test:JsonGetBoolInvalid() {
    new Node:node = JSON_Object("k", JSON_String("v"));
    new bool:gotBool;
    new ret = JSON_GetBool(node, "key4", gotBool);
    ASSERT(ret == 2);
}

Test:JsonGetStringInvalid() {
    new Node:node = JSON_Object("k", JSON_String("v"));
    new gotString[1];
    new ret = JSON_GetString(node, "key4", gotString);
    ASSERT(ret == 2);
}

Test:JsonGetArrayInvalid() {
    new Node:node = JSON_Object("k", JSON_String("v"));
    new Node:gotNode;
    new ret = JSON_GetArray(node, "key4", gotNode);
    ASSERT(ret == 2);
}

Test:JSON_ArrayLength() {
    new Node:node = JSON_Array(
        JSON_String("one"),
        JSON_String("two"),
        JSON_String("three")
    );

    new length;
    new ret;
    ret = JSON_ArrayLength(node, length);
    printf("ret %d length %d", ret, length);
    ASSERT(ret == 0);
    ASSERT(length == 3);
}

Test:JSON_ArrayObject() {
    new Node:node = JSON_Array(
        JSON_String("one"),
        JSON_String("two"),
        JSON_String("three")
    );

    new Node:output;
    new ret;
    ret = JSON_ArrayObject(node, 1, output);
    ASSERT(ret == 0);

    new got[32];
    ret = JSON_GetNodeString(output, got);
    ASSERT(ret == 0);
    ASSERT(!strcmp(got, "two"));
}

Test:JsonGetNodeInt() {
    new Node:node = JSON_Object(
        "key", JSON_Int(1)
    );

    new Node:output;
    new ret;
    ret = JSON_GetObject(node, "key", output);
    ASSERT_EQ(ret, 0);

    new got;
    ret = JSON_GetNodeInt(output, got);
    ASSERT_EQ(ret, 0);
    ASSERT_EQ(got, 1);
}

Test:JsonGetNodeFloat() {
    new Node:node = JSON_Object(
        "key", JSON_Float(1.34)
    );

    new Node:output;
    new ret;
    ret = JSON_GetObject(node, "key", output);
    ASSERT(ret == 0);

    new Float:got;
    ret = JSON_GetNodeFloat(output, got);
    ASSERT(ret == 0);
    ASSERT(got == 1.34);
}

Test:JsonGetNodeBool() {
    new Node:node = JSON_Object(
        "key", JSON_Bool(true)
    );

    new Node:output;
    new ret;
    ret = JSON_GetObject(node, "key", output);
    ASSERT(ret == 0);

    new bool:got;
    ret = JSON_GetNodeBool(output, got);
    ASSERT(ret == 0);
    ASSERT(got == true);
}

Test:JsonGetNodeString() {
    new Node:node = JSON_Object(
        "key", JSON_String("value")
    );

    new Node:output;
    new ret;
    ret = JSON_GetObject(node, "key", output);
    ASSERT(ret == 0);

    new got[32];
    ret = JSON_GetNodeString(output, got);
    ASSERT(ret == 0);
    ASSERT(!strcmp(got, "value"));
}

Test:JsonScopeGC() {
    new Node:node = JSON_Object();
    scopeNodeGC(node);
    ASSERT(JSON_Cleanup(node) == 1);
}

Test:JsonToggleGC() {
    new Node:node = JSON_Object(
        "key", JSON_String("value")
    );
    JSON_ToggleGC(node, false);
    scopeNodeGC(node);
    new value[6];
    JSON_GetString(node, "key", value);
    ASSERT_SAME(value, "value");
    ASSERT_EQ(JSON_Cleanup(node), 0);
    ASSERT_EQ(JSON_Cleanup(node), 1);
}

Test:JsonArrayAppend() {
    new Node:arr = JSON_Array(
        JSON_Int(1),
        JSON_Int(2)
    );

    new Node:a = JSON_Object(
        "key1", arr
    );

    new ret = JSON_ArrayAppend(a, "key1", JSON_Int(3));
    ASSERT_EQ(ret, 0);

    new buf[128];
    ret = JSON_Stringify(a, buf);
    ASSERT_EQ(ret, 0);
    ASSERT(!strcmp(buf, "{\"key1\":[1,2,3]}"));
    print(buf);
}

scopeNodeGC(Node:node) {
    printf("scoped %d", _:node);
}
