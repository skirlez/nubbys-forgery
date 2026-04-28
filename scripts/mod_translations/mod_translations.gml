function load_mod_translations(wod) {
	var translation_folder = strip_initial_path_separator_character(wod.custom.forgery.translations_path);

	var trans_dir = $"{global.mods_directory}/{wod.folder_name}/{translation_folder}";
	var csv_files = get_all_files(trans_dir, "csv")
	for (var i = 0; i < array_length(csv_files); i++) {
		var file_path = $"{trans_dir}/{csv_files[i]}.csv";
		if file_exists(file_path) {
			var translation = load_csv(file_path)
			ds_map_add(wod.translations, csv_files[i], translation)
		}
	}	
}

function get_current_language_id() {
	var num = 0;
	for (var i = 0; i < array_length(global.LocDoc); i++) {
		if global.LocDoc[i] == 	global.TargetLocSheet {
			num = i;
			break;	
		}
	}
	switch (num) {
		default:
			return "en"
		case 1:
			return "pt-BR"
		case 2:
			return "da"
		case 3:
			return "it"
		case 4:
			return "ca"
		case 5:
			return "sk"
		case 6:
			return "uk"
		case 7:
			return "pt"
		case 8:
			return "fr"
		case 9:
			return "pl"
		case 10:
			// TODO!!!!!! choose between this (ugly) and es-LA (weird since it's for "Latin America" and not "Laos")
			// also TODO: give up on forgery having its own naming scheme and let/(require?) people to use names matching base game files
			return "es-419"
	}
}

// Called after scr_InitTranslations()
function append_mod_translations() {
	// treated as a hashset - only value inserted is `true`
	static overriden_translations = ds_map_create()
	ds_map_clear(overriden_translations)
	
	var lang = get_current_language_id();
	var is_english = (lang == "en")
	
	// global.Translations is a ds_map, mapping keys to rows on the csv
	// global.LocData is the base game csv ds_grid
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	sort_by_mod_order(mods)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		
		// treated as a hashset - only value inserted is `true`
		// keeps track of which translations have been added by this mod so that the english fallback translations
		// don't override new keys that were already overriden by the first language
		var keys_touched_set = noone;
		
		if ds_map_exists(wod.translations, lang) {
			keys_touched_set = append_translations(ds_map_find_value(wod.translations, lang), is_english, overriden_translations)
		}

		// always append english keys if we have them (as a fallback)
		if is_english 
			continue; // english already appended
		if !ds_map_exists(wod.translations, "en")
			continue;
		append_translations(ds_map_find_value(wod.translations, "en"), false, overriden_translations, keys_touched_set)
		
		if (keys_touched_set != noone)
			ds_map_destroy(keys_touched_set)
	}
}


function count_keys_that_will_be_added(loc_data) {
	var count = 0
	for (var i = 0; i < ds_grid_height(loc_data); i++) {
		var key = ds_grid_get(loc_data, 0, i);
		if !ds_map_exists(global.Translations, key)
			count++;
	}
	return count
}

function append_translations(loc_data, is_english, overriden_translations_set, do_not_override_set = noone) {
	// TODO error handling if the mod csv isn't two values per row. Check here and log
	var h = ds_grid_height(global.LocData)
	ds_grid_resize(global.LocData, ds_grid_width(global.LocData), 
		h + count_keys_that_will_be_added(loc_data))
	
	var keys_touched = ds_map_create();
	
	var count = 0;
	for (var i = 0; i < ds_grid_height(loc_data); i++) {
		var key = ds_grid_get(loc_data, 0, i);
		var line;
		if ds_map_exists(global.Translations, key) {
			if (ds_map_exists(overriden_translations_set, key))
					|| (do_not_override_set != noone && ds_map_exists(do_not_override_set, key)) {
				continue;
			}
			ds_map_set(overriden_translations_set, key, true)
			line = ds_map_find_value(global.Translations, key)
		}
		else {
			line = h + count;
			ds_map_set(global.Translations, key, line)
			
			count++;
		}
		
		ds_grid_set(global.LocData, 0, line, key)
		var empty = ""
		if is_english {
			ds_grid_set(global.LocData, 1, line, ds_grid_get(loc_data, 1, i))
			ds_grid_set(global.LocData, 2, line, empty)
		}
		else {
			// For every non-English csv, there is a redundant middle column which (presumably) should hold
			// the English translation to aid translators as they're translating the game. When the language is set to English,
			// the flag obj_Debug.ShowTestingTranslations controls whether or not to show column 2 instead of column 1.
			
			// Forgery does not bother with this.
 			ds_grid_set(global.LocData, 1, line, empty)
			ds_grid_set(global.LocData, 2, line, ds_grid_get(loc_data, 1, i))
		}
		
		
		ds_map_add(keys_touched, key, true)
	}	
	return keys_touched
}
