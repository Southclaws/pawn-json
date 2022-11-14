#[macro_use]
extern crate enum_primitive;

mod plugin;
mod pool;

use crate::plugin::Plugin;
use crate::pool::GarbageCollectedPool;
use samp::initialize_plugin;

initialize_plugin!(
    natives: [
            Plugin::json_parse,
            Plugin::json_parse_file,
            Plugin::json_save_file,
            Plugin::json_stringify,
            Plugin::json_node_type,
            Plugin::json_object,
            Plugin::json_int,
            Plugin::json_bool,
            Plugin::json_float,
            Plugin::json_string,
            Plugin::json_array,
            Plugin::json_append,
            Plugin::json_set_object,
            Plugin::json_set_array,
            Plugin::json_set_int,
            Plugin::json_set_float,
            Plugin::json_set_bool,
            Plugin::json_set_string,
            Plugin::json_get_object,
            Plugin::json_get_int,
            Plugin::json_get_float,
            Plugin::json_get_bool,
            Plugin::json_get_string,
            Plugin::json_get_array,
            Plugin::json_get_type,
            Plugin::json_array_length,
            Plugin::json_array_object,
            Plugin::json_array_iterate,
            Plugin::json_array_append,
            Plugin::json_array_remove,
            Plugin::json_array_remove_index,
            Plugin::json_array_clear,
            Plugin::json_keys,
            Plugin::json_remove,
            Plugin::json_get_node_int,
            Plugin::json_get_node_float,
            Plugin::json_get_node_bool,
            Plugin::json_get_node_string,
            Plugin::json_toggle_gc,
            Plugin::json_cleanup,
            Plugin::json_count_nodes
    ],
    {
        let samp_logger = samp::plugin::logger()
            .level(log::LevelFilter::Info);

        samp::encoding::set_default_encoding(samp::encoding::WINDOWS_1251);

        let _ = fern::Dispatch::new()
            .format(|callback, message, record| {
                callback.finish(format_args!("[pawn-json] [{}]: {}", record.level().to_string().to_lowercase(), message))
            })
            .chain(samp_logger)
            .apply();

        Plugin {
            json_nodes:GarbageCollectedPool::default(),
        }
    }
);
