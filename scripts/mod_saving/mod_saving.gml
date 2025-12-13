// Supervisor unlocked/win/highscore data is saved per index. No good! Indices cannot be 
// consistent for modded resources. So we'll do all the progress saving for them in a separate file.

// Nubby has several "SaveIDs". They don't really seem consistent with what they save,

// ("Progression" stores challenge highscores, challenge beaten, and challenge wins,
// but only stores supervisors unlocked and wins, supervisor highscore is in "Highscore")

// but for now we're only saving exactly what those files save (but for forgery resources)


// called from gml_Object_obj_Saver_Alarm_0, after the "Progression" save ID 
function save_forgery_progression() {
	var filename = "Progression.forgery"
	var save = load_json_struct_or_default(filename, {
		supervisors : {}
	})
	
	var string_ids = bimap_lefts_array(global.registry[mod_resources.supervisor])
	for (var i = 0; i < array_length(string_ids); i++) {
		var string_id = string_ids[i]
		var index = mod_registries_exchange(global.registry, global.index_registry, 
			mod_resources.supervisor, string_id)
		save.supervisors[$ string_id] = {
			unlocked : bool(agi("obj_GAME").U_SV[index]),
			wins : agi("obj_GAME").SvWins[index],
		}
	}
	var save_string = json_stringify(save)
	var buf = buffer_create(string_byte_length(save_string) + 1, buffer_fixed, 1);
	buffer_write(buf, buffer_string, save_string);
	buffer_save(buf, filename);
	buffer_delete(buf);
}

// called from gml_Object_obj_Saver_Alarm_0, after the "Highscore" save ID 
function save_forgery_highscore() {
	var filename = "Highscore.forgery"

	var save = load_json_struct_or_default(filename, {
		supervisors : {}
	})
	
	var string_ids = bimap_lefts_array(global.registry[mod_resources.supervisor])
	for (var i = 0; i < array_length(string_ids); i++) {
		var string_id = string_ids[i]
		var index = mod_registries_exchange(global.registry, global.index_registry, 
			mod_resources.supervisor, string_id)
		save.supervisors[$ string_id] = {
			highscore : agi("obj_GAME").SV_HS[index],
		}
	}
	var save_string = json_stringify(save)
	var buf = buffer_create(string_byte_length(save_string) + 1, buffer_fixed, 1);
	buffer_write(buf, buffer_string, save_string);
	buffer_save(buf, filename);
	buffer_delete(buf);
}



function load_forgery_highscore() {
	var save = load_json_struct_or_default("Highscore.forgery", { supervisors : {} })
	var s = save.supervisors
	var string_ids_in_save = variable_struct_get_names(s)
	var string_ids = bimap_lefts_array(global.registry[mod_resources.supervisor])
		
	for (var i = 0; i < array_length(string_ids); i++) {
		var string_id = string_ids[i]
		var index = mod_registries_exchange(global.registry, global.index_registry, 
			mod_resources.supervisor, string_id)
		if index == undefined
			continue; // shouldn't happen	
		with (agi("obj_GAME")) {
			if array_contains(string_ids_in_save, string_id) {
				SV_HS[index] = s[$ string_id].highscore
			}
			else {
				// see comment in load_forgery_progression below on why this is done
				SV_HS[index] = 0
			}
		}
	}
}

function load_forgery_progression() {
	var save = load_json_struct_or_default("Progression.forgery", { supervisors : {} })
	var s = save.supervisors
	var string_ids_in_save = variable_struct_get_names(s)
	var string_ids = bimap_lefts_array(global.registry[mod_resources.supervisor])
	for (var i = 0; i < array_length(string_ids); i++) {
		var string_id = string_ids[i]
		var index = mod_registries_exchange(global.registry, global.index_registry, 
			mod_resources.supervisor, string_id)
		if index == undefined
			continue; // shouldn't happen	
		with (agi("obj_GAME")) {
			if array_contains(string_ids_in_save, string_id) {
				SvWins[index] = s[$ string_id].wins
				U_SV[index] = s[$ string_id].unlocked
			}
			else {
				// may seem redundant, but this is necessary; since index 12 is reserved but empty,
				// it is actually functional for the purpose of saving data. so if you have a modded supervisor
				// on that index, it will actually save everything properly to index 12.
				
				// changing this is a problem, so instead we opt to reset modded supervisor data
				// if they don't explicitly exist in the modded save.
				
				SvWins[index] = 0
				U_SV[index] = false;
			}
		}
	}
}
/*
function load_forgery_generic(filename, field, fallback = noone) {
	log_info($"Loading accompanying save file: \"{filename}\"")
	var data = load_json_struct_or_default(filename, noone)
	if data == noone
		return fallback;
	
	with (agi("obj_SaveDataMGMT")) {
		if !variable_instance_exists(id, "forgery")
			forgery = {}
		forgery[$ field] = data;
	}
	return data;
}
*/

function load_json_struct_or_default(filename, fallback) {
	if !file_exists(filename)
		return fallback;
	var load_string;
	var buf;
	try {
		buf = buffer_load(filename);
		load_string = buffer_read(buf, buffer_string);
	}
	catch (e) {
		buffer_delete(buf);
		return fallback
	}
	buffer_delete(buf);
	
	try {
		var data = json_parse(load_string);
	}
	
	return data;
}