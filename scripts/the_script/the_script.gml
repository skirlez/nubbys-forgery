// Everything used to be in this script. Then I put things in other scripts.
#macro agi asset_get_index

function create_mod(mod_folder_name) {
	var mod_definition_file = file_text_open_read($"{global.mods_directory}/{mod_folder_name}/mod.json")
	if (mod_definition_file == -1) {
		return new result_error(new generic_error(
			$"Could not find mod.json for mod folder {mod_folder_name}"));
	}
	var mod_definition_string = ""
	while (!file_text_eof(mod_definition_file)) {
		mod_definition_string += file_text_readln(mod_definition_file) + "\n"
	}
	file_text_close(mod_definition_file)
		
	try {
		var wod = json_parse(mod_definition_string)
	}
	catch (e) {
		return new result_error(new generic_error(
			$"Error while parsing mod.json in mod folder {mod_folder_name}: {pretty_error(e)}"));
	}
	
	if !variable_struct_exists(wod, "custom")
		return new result_ok(new optional_empty())
	if !is_struct(wod.custom) || !variable_struct_exists(wod.custom, "forgery")
		return new result_ok(new optional_empty())
		
	static mod_contract = {
		mod_id : "",
		display_name : "",
		description : "",
		version : "",
		credits : [],
		custom : {
			forgery : {
				entrypoint : { type : ""},
				translations_path : "",
				compile_all_code_on_load : false
			}
		},
	}
	
	var compliance = get_struct_compliance_with_contract(wod, mod_contract)
	if is_discompilant(compliance) {
		return compliance_error(wod, mod_contract, compliance,
			$"mod.json in {mod_folder_name} has bad variables")
	}
	
	// TODO validate credits
	
	wod.folder_name = mod_folder_name;
	wod.translations = ds_map_create();
	
	load_mod_translations(wod)
	
	wod.code_files = ds_map_create();
	wod.functions = ds_map_create();

	if wod.custom.forgery.compile_all_code_on_load {
		log_info($"Compiling all files belonging to mod {wod.mod_id}")
		compile_all_files_in_path_recursively("/", wod, wod.code_files)
	}
	
	var entrypoint = wod.custom.forgery.entrypoint;
	
	global.cmod = wod;
	if entrypoint.type == "runtime" {
		static entrypoint_runtime_contract = {
			type : "",
			path : "",
		}
		var entrypoint_runtime_compliance = get_struct_compliance_with_contract(entrypoint, entrypoint_runtime_contract)
		if is_discompilant(entrypoint_runtime_compliance) {
			return compliance_error(wod, entrypoint_runtime_contract, entrypoint_runtime_compliance,
				$"mod.json in {mod_folder_name} has bad entrypoint variables")
		}
		
		try {
			var mod_globals = mod_get_code_globals(entrypoint.path, wod)
		}
		catch (e) {
			return new result_error(new generic_error(e))
		}

		static mod_globals_contract = {
			on_load : global.empty_method,
			on_unload : global.empty_method,
		}
		var mod_globals_compliance = get_struct_compliance_with_contract(mod_globals, mod_globals_contract)
		if is_discompilant(mod_globals_compliance) {
			return new result_error(new generic_error(
				$"Mod entrypoint {entrypoint} has bad variables:\n" 
				+ generate_compliance_error_text(mod_globals, mod_globals_contract, compliance)
			))
		}
		
		wod.on_load = mod_globals.on_load;
		wod.on_unload = mod_globals.on_unload;
	}
	else if entrypoint.type == "compiled" {
		static entrypoint_compiled_contract = {
			type : "",
			on_load : "",
			on_unload : ""
		}
		var entrypoint_compiled_compliance = get_struct_compliance_with_contract(entrypoint, entrypoint_runtime_contract)
		if is_discompilant(entrypoint_compiled_compliance) {
			return compliance_error(wod, entrypoint_compiled_contract, entrypoint_compiled_compliance,
				$"mod.json in {mod_folder_name} has bad entrypoint variables")
		}
		wod.on_load = agi(entrypoint.on_load);
		wod.on_unload = agi(entrypoint.on_unload);
	}
	else {
		return new result_error(new generic_error(
			$"mod.json in {mod_folder_name} has invalid entrypoint type: {entrypoint.type}\n"
			+ "(valid: \"runtime\", \"compiled\")"
		))	
	}
	
	
	wod.items = []
	wod.perks = []
	wod.supervisors =  []
	//wod.foods = ds_map_create();
	wod.sprites = ds_map_create();
	wod.sounds = ds_map_create();
	
	
	wod.game_events = [];
	wod.callback_records = [];
	wod.autosave_save_callbacks = []
	wod.autosave_load_callbacks = []
	
	// TODO check invalid characters
	return new result_ok(new optional_value(wod))
}


function compile_all_files_in_path_recursively(path, map, wod) {
	var type = mod_get_code_type(path)
	var files = get_all_files(path, ".meow")
	for (var i = 0; i < array_length(files); i++) {
		var main;
		try {
			main = compile_code_file($"{path}{files[i]}.meow");
		}
		catch (e) {
			log_error($"While compiling all files, {path} errored on compilation: {pretty_error(e)}")
			continue;
		}
		ds_map_add(map, files[i], main)
	}
	
	var folders = get_all_directories(path)
	for (var i = 0; i < array_length(folders); i++) {
		var folder_name = folders[i]
		var folder_map = ds_map_create();
		ds_map_add_map(map, folders[i], folder_map)
		compile_all_files_in_path_recursively($"{path}/{folder_name}", folder_map, wod)
	}
}


// For catspeak use
function mod_execute_code(path, wod = global.cmod) {
	try {
		var code = mod_get_code(path, wod)
		execute(code)
	}
	catch (e) {
		log_error($"While calling mod_execute_code (path: {path}): " + pretty_error(e))	
	}
}
// For catspeak use
function mod_get_code_globals(path, wod = global.cmod) {
	var code = mod_get_code(path, wod)
	var globals = catspeak_globals(code);
	if variable_struct_names_count(globals) == 0 {
		try {
			execute(code)
		}
		catch (e) {
			log_error($"While calling mod_get_code_globals (path: {path}): " + pretty_error(e))	
		}
	}
	return globals;
}

/*
TODO:
I cannot remember why I implemented code_files with nested maps.
I don't think it needs nested maps. Could just have code_files be a map of path strings to code files.
Probably should rewrite this to do that.
*/

// For gamemaker and catspeak use
function mod_get_code(path, wod = global.cmod) {
	var path_arr = string_split(path, "/", true)
	var current_thing = wod.code_files
	var current_full_directory = $"{global.mods_directory}/{wod.folder_name}";
	if array_length(path_arr) == 0 {
		throw $"Mod {wod.mod_id} requested code file from bad path ({path})"	
	}
	for (var i = 0; i < array_length(path_arr); i++) {
		var new_location = path_arr[i];
		var last_entry = i == array_length(path_arr) - 1;
		if !ds_map_exists(current_thing, new_location) {
			var error_message = $"Mod {wod.mod_id} requested code file from {path}, but {new_location} does not exist";
			if !(last_entry) {
				// missing folder
				if !directory_exists($"{current_full_directory}/{new_location}")
					throw error_message;
				ds_map_add_map(current_thing, new_location, ds_map_create())
			}
			else {
				// missing file
				if !file_exists($"{current_full_directory}/{new_location}")
					throw error_message;
				
				var main;
				try {
					main = compile_code_file($"{current_full_directory}/{new_location}");
				}
				catch (e) {
					throw $"Mod {wod.mod_id} requested file {path} which errored on compilation: {pretty_error(e)}"	
				}
				ds_map_add(current_thing, new_location, main)
				return main;
			}
		}
		
		if !ds_map_is_map(current_thing, new_location) && !last_entry
				|| (ds_map_is_map(current_thing, new_location) && last_entry) {
			throw $"Requested code file from bad path ({path})"
		}
		current_thing = ds_map_find_value(current_thing, new_location)
		current_full_directory += $"/{new_location}"
	}
	return current_thing;
	
}
function strip_initial_path_separator_character(path) {
	if string_starts_with(path, "/") || string_starts_with(path, "\\")
		path = string_delete(path, 1, 1)	
	return path
}


function unload_mod(wod) {
	log_info($"Unloading mod {wod.mod_id}")
	global.cmod = wod;
	try {
		wod.on_unload();
	}
	catch (e) {
		log_error($"Mod {wod.mod_id} errored while unloading: {pretty_error(e)}")
	}
	
	// Remove any Game Event callbacks this mod has
	for (var i = 0; i < array_length(wod.callback_records); i++) {
		var callback = wod.callback_records[i].callback;
		var game_event_name = wod.callback_records[i].game_event_name;
		
		var callback_mod_structs = ds_map_find_value(global.forgery_game_events, game_event_name)
		for (var j = 0; j < array_length(callback_mod_structs); j++) {
			if (callback_mod_structs[j].callback == callback) {
				array_delete(callback_mod_structs, j, 1)
				break;	
			}
		}
		if array_length(callback_mod_structs) == 0
			ds_map_delete(global.forgery_game_events, game_event_name);
	}
	
	for (var i = 0; i < array_length(wod.items); i++) {
		bimap_delete_right(global.registry[mod_resources.item], wod.items[i])	
	}
	for (var i = 0; i < array_length(wod.perks); i++) {
		bimap_delete_right(global.registry[mod_resources.perk], wod.perks[i])	
	}
	for (var i = 0; i < array_length(wod.supervisors); i++) {
		bimap_delete_right(global.registry[mod_resources.supervisor], wod.supervisors[i])	
	}
	
	var translation_keys = ds_map_keys_to_array(wod.translations)
	for (var i = 0; i < array_length(translation_keys); i++) {
		ds_grid_destroy(ds_map_find_value(wod.translations, translation_keys[i]))	
	}
	ds_map_destroy(wod.translations)
		
	var sprite_keys = ds_map_keys_to_array(wod.sprites)
	for (var i = 0; i < array_length(sprite_keys); i++) {
		var sprite = ds_map_find_value(wod.sprites, sprite_keys[i]);
		if sprite >= global.sprite_count
			sprite_delete(sprite)
	}
	ds_map_destroy(wod.sprites)
	
	var sound_keys = ds_map_keys_to_array(wod.sounds)
	for (var i = 0; i < array_length(sound_keys); i++) {
		var sound = ds_map_find_value(wod.sounds, sound_keys[i])
		if (sound >= global.sound_count)
			audio_destroy_stream(sound)
	}
	ds_map_destroy(wod.sounds)
	
	ds_map_destroy(wod.code_files)
	
	ds_map_destroy(wod.functions)
	
	remove_mod_from_run_delayed(wod)
	
	ds_map_delete(global.mod_id_to_mod_map, wod.mod_id);
}


function clear_all_mods() {
	log_info("Clearing/Unloading all mods")
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i]
		unload_mod(wod)
	}
	ds_map_clear(global.mod_id_to_mod_map)
	registry_clear(global.registry)
	registry_clear(global.index_registry)
}


// Reads all mods and returns a list of their structs
function read_all_mods() {
	var folders = get_all_directories(global.mods_directory)
	for (var i = 0; i < array_length(folders); i++) {
		var mod_folder_name = folders[i];
		var mod_result = create_mod(mod_folder_name)
		if (mod_result.is_error()) {
			log_error(mod_result.error.text)
			continue;
		}
		var wod_maybe = mod_result.value
		if (wod_maybe.is_empty)
			continue;
		var wod = wod_maybe.get()
		ds_map_set(global.mod_id_to_mod_map, wod.mod_id, wod);
		
		try {
			global.cmod = wod;
			wod.on_load();
		}
		catch (e) {
			log_error($"Mod {wod.mod_id} errored on load: {pretty_error(e)}")
			// TODO what to do
			unload_mod(wod)
			continue;
		}
		log_info($"Mod {wod.mod_id} successfully loaded")
		
		
	}
}


function is_console_and_devmode_enabled() {
	return true;	
}
function reroll_cheats_enabled() {
	return false;	
}

function pretty_error(e) {
	// TODO
	return string(e);
}

function hot_reload() {
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i]
		ds_map_clear(wod.code_files)
		/*
		for (var j = 0; j < array_length(wod.items); j++) {
			var item = wod.items[j];
		}
		*/
	}
}
function get_nf_version_string() {
	return "Nubby's Forgery BETA V5"	
}
function get_nf_loaded_string() {
	return $"({ds_map_size(global.mod_id_to_mod_map)} mod(s) loaded, "
		+ $"{bimap_size(global.registry[mod_resources.item])} item(s), "
		+ $"{bimap_size(global.registry[mod_resources.perk])} perk(s), "
		+ $"{bimap_size(global.registry[mod_resources.supervisor])} supervisor(s))"
}