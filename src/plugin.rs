use log::{debug, error};
use samp::native;
use samp::prelude::*;

use crate::pool::GarbageCollectedPool;

pub struct Plugin {
    pub json_nodes: GarbageCollectedPool<serde_json::Value>,
}

enum_from_primitive! {
#[derive(Debug, PartialEq, Clone)]
enum JsonNode {
    Number = 0,
    Boolean,
    String,
    Object,
    Array,
    Null,
}
}

impl SampPlugin for Plugin {}

impl Plugin {
    #[native(name = "JSON_Parse")]
    pub fn json_parse(&mut self, _: &Amx, input: AmxString, mut node: Ref<i32>) -> AmxResult<i32> {
        let v: serde_json::Value = match serde_json::from_str(&input.to_string()) {
            Ok(v) => v,
            Err(e) => {
                error!("{}", e);
                return Ok(1);
            }
        };

        *node = self.json_nodes.alloc(v);

        Ok(0)
    }

    #[native(name = "JSON_Stringify")]
    pub fn json_stringify(
        &mut self,
        _: &Amx,
        node: i32,
        output: UnsizedBuffer,
        length: usize,
    ) -> AmxResult<i32> {
        let v: &serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };

        let s = match serde_json::to_string(&v) {
            Ok(v) => v,
            Err(e) => {
                error!("{}", e);
                return Ok(1);
            }
        };

        let mut dest = output.into_sized_buffer(length);
        let _ = samp::cell::string::put_in_buffer(&mut dest, &s);

        Ok(0)
    }

    #[native(name = "JSON_NodeType")]
    pub fn json_node_type(&mut self, _: &Amx, node: i32) -> AmxResult<i32> {
        let v: &serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => &serde_json::Value::Null,
        };

        debug!("{:?}", v);

        let t: i32 = match v {
            serde_json::Value::Null => JsonNode::Null as i32,
            serde_json::Value::Bool(_) => JsonNode::Boolean as i32,
            serde_json::Value::Number(_) => JsonNode::Number as i32,
            serde_json::Value::String(_) => JsonNode::String as i32,
            serde_json::Value::Array(_) => JsonNode::Array as i32,
            serde_json::Value::Object(_) => JsonNode::Object as i32,
        };

        Ok(t)
    }

    #[native(raw, name = "JSON_Object")]
    pub fn json_object(&mut self, _: &Amx, mut params: samp::args::Args) -> AmxResult<i32> {
        let arg_count = params.count();
        let pairs = if arg_count == 0 || arg_count % 2 == 0 {
            arg_count / 2
        } else {
            error!("invalid variadic argument pattern passed to JSON_Object");
            return Ok(1);
        };

        let mut v = serde_json::Value::Object(serde_json::Map::new());
        for _ in 0..pairs {
            let key = match params.next::<AmxString>() {
                None => {
                    error!("invalid type expected String");
                    return Ok(2);
                }
                Some(parameter) => parameter,
            };

            let node = match params.next::<Ref<i32>>() {
                None => {
                    error!("invalid type expected int");
                    return Ok(2);
                }
                Some(parameter) => parameter,
            };

            let node = match self.json_nodes.take(*node) {
                Some(v) => v,
                None => {
                    error!("invalid JSON node ID passed to JSON_Object");
                    return Ok(2);
                }
            };

            v[key.to_string()] = node.clone();
        }

        Ok(self.json_nodes.alloc(v))
    }

    #[native(name = "JSON_Int")]
    pub fn json_int(&mut self, _: &Amx, value: i32) -> AmxResult<i32> {
        Ok(self.json_nodes.alloc(serde_json::to_value(value).unwrap()))
    }

    #[native(name = "JSON_Bool")]
    pub fn json_bool(&mut self, _: &Amx, value: bool) -> AmxResult<i32> {
        Ok(self.json_nodes.alloc(serde_json::to_value(value).unwrap()))
    }

    #[native(name = "JSON_Float")]
    pub fn json_float(&mut self, _: &Amx, value: f32) -> AmxResult<i32> {
        Ok(self.json_nodes.alloc(serde_json::to_value(value).unwrap()))
    }

    #[native(name = "JSON_String")]
    pub fn json_string(&mut self, _: &Amx, value: AmxString) -> AmxResult<i32> {
        Ok(self
            .json_nodes
            .alloc(serde_json::to_value(value.to_string()).unwrap()))
    }

    #[native(raw, name = "JSON_Array")]
    pub fn json_array(&mut self, _: &Amx, mut params: samp::args::Args) -> AmxResult<i32> {
        let args = params.count();

        let mut arr = Vec::<serde_json::Value>::new();
        for _ in 0..args {
            let node = match params.next::<Ref<i32>>() {
                None => {
                    error!("invalid type expected int");
                    return Ok(1);
                }
                Some(parameter) => parameter,
            };

            let node = match self.json_nodes.take(*node) {
                Some(v) => v,
                None => {
                    error!("invalid JSON node ID passed to JSON_Array");
                    return Ok(1);
                }
            };
            arr.push(node.clone());
        }

        Ok(self.json_nodes.alloc(serde_json::Value::Array(arr)))
    }

    #[native(name = "JSON_Append")]
    pub fn json_append(&mut self, _: &Amx, a: i32, b: i32) -> AmxResult<i32> {
        let a: serde_json::Value = match self.json_nodes.take(a) {
            Some(v) => v,
            None => return Ok(-1),
        };
        let b: serde_json::Value = match self.json_nodes.take(b) {
            Some(v) => v,
            None => return Ok(-1),
        };

        match (a.as_object(), b.as_object()) {
            (Some(oa), Some(ob)) => {
                let mut new = serde_json::Value::Object(serde_json::Map::new());
                for (k, v) in oa.iter() {
                    new.as_object_mut().unwrap().insert(k.clone(), v.clone());
                }
                for (k, v) in ob.iter() {
                    new.as_object_mut().unwrap().insert(k.clone(), v.clone());
                }
                return Ok(self.json_nodes.alloc(new));
            }
            _ => debug!("append: a and b are not both objects"),
        };

        match (a.as_array(), b.as_array()) {
            (Some(oa), Some(ob)) => {
                let mut new = serde_json::Value::Array(Vec::new());
                for v in oa.iter() {
                    new.as_array_mut().unwrap().push(v.clone());
                }
                for v in ob.iter() {
                    new.as_array_mut().unwrap().push(v.clone());
                }
                return Ok(self.json_nodes.alloc(new));
            }
            _ => debug!("append: a and b are not both arrays"),
        };

        debug!("failed to append: a and b are not both objects or arrays");

        Ok(2)
    }

    #[native(name = "JSON_SetObject")]
    pub fn json_set_object(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: i32,
    ) -> AmxResult<i32> {
        let src: serde_json::Value = match self.json_nodes.take(value) {
            Some(v) => v,
            None => return Ok(1),
        };
        let dst: &mut serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        if !src.is_object() || !dst.is_object() {
            return Ok(1);
        }

        dst[key.to_string()] = src;
        Ok(0)
    }

    #[native(name = "JSON_SetArray")]
    pub fn json_set_array(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: i32,
    ) -> AmxResult<i32> {
        let src: serde_json::Value = match self.json_nodes.take(value) {
            Some(v) => v,
            None => return Ok(1),
        };
        let dst: &mut serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        if !src.is_array() || !dst.is_object() {
            return Ok(1);
        }

        dst[key.to_string()] = src;
        Ok(0)
    }    

    #[native(name = "JSON_SetInt")]
    pub fn json_set_int(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: i32,
    ) -> AmxResult<i32> {
        let v: &mut serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        if !v.is_object() {
            return Ok(1);
        }

        v[key.to_string()] = serde_json::to_value(value).unwrap();
        Ok(0)
    }

    #[native(name = "JSON_SetFloat")]
    pub fn json_set_float(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: f32,
    ) -> AmxResult<i32> {
        let v: &mut serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        if !v.is_object() {
            return Ok(1);
        }

        v[key.to_string()] = serde_json::to_value(value).unwrap();
        Ok(0)
    }

    #[native(name = "JSON_SetBool")]
    pub fn json_set_bool(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: bool,
    ) -> AmxResult<i32> {
        let v: &mut serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        if !v.is_object() {
            return Ok(1);
        }

        v[key.to_string()] = serde_json::to_value(value).unwrap();
        Ok(0)
    }

    #[native(name = "JSON_SetString")]
    pub fn json_set_string(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: AmxString,
    ) -> AmxResult<i32> {
        let v: &mut serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        if !v.is_object() {
            return Ok(1);
        }

        v[key.to_string()] = serde_json::to_value(value.to_string()).unwrap();
        Ok(0)
    }

    #[native(name = "JSON_GetObject")]
    pub fn json_get_object(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        mut value: Ref<i32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_object() {
            Some(v) => v,
            None => return Ok(2),
        };
        let v = match v.get(&key.to_string()) {
            Some(v) => v.clone(),
            None => return Ok(3),
        };
        let v = self.json_nodes.alloc(v);
        *value = v;

        Ok(0)
    }

    #[native(name = "JSON_GetInt")]
    pub fn json_get_int(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        mut value: Ref<i32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_object() {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.get(&key.to_string()) {
            Some(v) => v.clone(),
            None => return Ok(2),
        };
        let v = match v.as_i64() {
            Some(v) => v as i32,
            None => return Ok(3),
        };
        *value = v;

        Ok(0)
    }

    #[native(name = "JSON_GetFloat")]
    pub fn json_get_float(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        mut value: Ref<f32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_object() {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.get(&key.to_string()) {
            Some(v) => v.clone(),
            None => return Ok(2),
        };
        let v = match v.as_f64() {
            Some(v) => v as f32,
            None => return Ok(3),
        };

        *value = v;

        Ok(0)
    }

    #[native(name = "JSON_GetBool")]
    pub fn json_get_bool(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        mut value: Ref<bool>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_object() {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.get(&key.to_string()) {
            Some(v) => v.clone(),
            None => return Ok(2),
        };
        let v = match v.as_bool() {
            Some(v) => v,
            None => return Ok(3),
        };
        *value = v;
        Ok(0)
    }

    #[native(name = "JSON_GetString")]
    pub fn json_get_string(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        value: UnsizedBuffer,
        length: usize,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_object() {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.get(&key.to_string()) {
            Some(v) => v.clone(),
            None => return Ok(2),
        };
        let v = match v.as_str() {
            Some(v) => v,
            None => return Ok(3),
        };

        let mut dest = value.into_sized_buffer(length);
        let _ = samp::cell::string::put_in_buffer(&mut dest, &v);

        Ok(0)
    }

    #[native(name = "JSON_GetArray")]
    pub fn json_get_array(
        &mut self,
        _: &Amx,
        node: i32,
        key: AmxString,
        mut value: Ref<i32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_object() {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.get(&key.to_string()) {
            Some(v) => v.clone(),
            None => return Ok(2),
        };
        match v.as_array() {
            Some(_) => (),
            None => return Ok(3),
        };
        let v = self.json_nodes.alloc(v);
        *value = v;
        Ok(0)
    }

    #[native(name = "JSON_ArrayLength")]
    pub fn json_array_length(
        &mut self,
        _: &Amx,
        node: i32,
        mut length: Ref<i32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_array() {
            Some(v) => v,
            None => return Ok(1),
        };
        *length = v.len() as i32;
        Ok(0)
    }

    #[native(name = "JSON_ArrayObject")]
    pub fn json_array_object(
        &mut self,
        _: &Amx,
        node: i32,
        index: i32,
        mut output: Ref<i32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.get(node) {
            Some(v) => v.clone(),
            None => return Ok(1),
        };
        let v = match v.as_array() {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.get(index as usize) {
            Some(v) => v.clone(),
            None => return Ok(2),
        };
        let v = self.json_nodes.alloc(v);
        *output = v;
        Ok(0)
    }

    #[native(name = "JSON_GetNodeInt")]
    pub fn json_get_node_int(
        &mut self,
        _: &Amx,
        node: i32,
        mut output: Ref<i32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.take(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.as_i64() {
            Some(v) => v as i32,
            None => return Ok(1),
        };
        *output = v;
        Ok(0)
    }

    #[native(name = "JSON_GetNodeFloat")]
    pub fn json_get_node_float(
        &mut self,
        _: &Amx,
        node: i32,
        mut output: Ref<f32>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.take(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.as_f64() {
            Some(v) => v as f32,
            None => return Ok(1),
        };
        *output = v;
        Ok(0)
    }

    #[native(name = "JSON_GetNodeBool")]
    pub fn json_get_node_bool(
        &mut self,
        _: &Amx,
        node: i32,
        mut output: Ref<bool>,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.take(node) {
            Some(v) => v,
            None => return Ok(1),
        };
        let v = match v.as_bool() {
            Some(v) => v,
            None => return Ok(1),
        };
        *output = v;
        Ok(0)
    }

    #[native(name = "JSON_GetNodeString")]
    pub fn json_get_node_string(
        &mut self,
        _: &Amx,
        node: i32,
        output: UnsizedBuffer,
        length: usize,
    ) -> AmxResult<i32> {
        let v: serde_json::Value = match self.json_nodes.take(node) {
            Some(v) => v,
            None => {
                debug!("value under {} doesn't exist", node);
                return Ok(1);
            }
        };
        let v = match v.as_str() {
            Some(v) => v,
            None => {
                debug!("value is not a string {:?}", v);
                return Ok(1);
            }
        };
        let mut dest = output.into_sized_buffer(length);
        let _ = samp::cell::string::put_in_buffer(&mut dest, &v);

        Ok(0)
    }

    #[native(name = "JSON_ToggleGC")]
    pub fn json_toggle_gc(&mut self, _: &Amx, node: i32, set: bool) -> AmxResult<i32> {
        match self.json_nodes.set_gc(node, set) {
            Some(_) => Ok(0),
            None => Ok(1),
        }
    }

    #[native(name = "JSON_Cleanup")]
    pub fn json_cleanup(&mut self, _: &Amx, node: i32, auto: bool) -> AmxResult<i32> {
        match if auto {
            self.json_nodes.collect(node)
        } else {
            self.json_nodes.collect_force(node)
        } {
            Some(_) => Ok(0),
            None => Ok(1),
        }
    }
}
