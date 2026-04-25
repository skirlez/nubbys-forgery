
function create_api_objects() {
	global.forgery_9 = fixup({
		register_item : mod_register_item,
		register_perk : mod_register_perk,
		register_supervisor : mod_register_supervisor,
		register_challenge : mod_register_challenge,
		
		register_autosave_save_callback : mod_register_autosave_save_callback,
		register_autosave_load_callback : mod_register_autosave_load_callback,
		
		register_function_catspeak : mod_register_function_catspeak,
		
		register_sound : mod_register_sound,
		get_sound : mod_get_sound,
		
		register_sprite : mod_register_sprite,
		get_sprite : mod_get_sprite,
		
		run_delayed : mod_run_delayed,
		
		registry_get_left : mod_registry_get_left,
		registry_get_right : mod_registry_get_right,
		registry_left_exists : mod_registry_left_exists,
		registry_right_exists : mod_registry_right_exists,
		registries_exchange : mod_registries_exchange,
		
		subscribe_to_game_event : mod_subscribe_to_game_event,
		
		log : mod_log,
		
		get_path : mod_get_path,
		
		get_code : mod_get_code,
		get_code_globals : mod_get_code_globals,
		execute_code : mod_execute_code,
		identifier : mod_identifier,
		
		resources : {
			item : mod_resources.item,
			perk : mod_resources.perk,
			supervisor : mod_resources.supervisor
		}
	});
	global.forgery_7 = global.forgery_9
}

function get_forgery_api_object_versions() {
	return [7, 9]	
}

function fixup(struct) {
	var arr = struct_get_names(struct)
	for (var i = 0; i < array_length(arr); i++) {
		var variable_name = arr[i];
		var value = struct[$ variable_name]
		if typeof(value) == "struct"
			struct[$ variable_name] = fixup(value)
		if typeof(value) == "ref" && is_callable(value) && !is_method(value)
			struct[$ variable_name] = method(undefined, value)
	}
	return struct
}