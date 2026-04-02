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
	}
}

// Called after scr_InitTranslations()
function append_mod_translations() {
	var lang = get_current_language_id();
	var is_english = (lang == "en")
	
	// global.Translations is a ds_map, mapping keys to rows on the csv
	// global.LocData is the base game csv ds_grid
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		
		if ds_map_exists(wod.translations, lang) {
			append_translations(ds_map_find_value(wod.translations, lang), is_english)
		}

		// always append english keys if we have them (as a fallback)
		if is_english 
			continue; // english already appended
		if !ds_map_exists(wod.translations, "en")
			continue;
		append_translations(ds_map_find_value(wod.translations, "en"), false)
	}
}


function count_keys_not_already_added(loc_data) {
	var count = 0
	for (var i = 0; i < ds_grid_height(loc_data); i++) {
		var key = ds_grid_get(loc_data, 0, i);
		if !ds_map_exists(global.Translations, key)
			count++;
	}
	return count
}

function append_translations(loc_data, is_english) {
	// TODO error handling if the mod csv isn't two values per row. Check here and log
	var h = ds_grid_height(global.LocData)
	ds_grid_resize(global.LocData, ds_grid_width(global.LocData), 
		h + count_keys_not_already_added(loc_data))
	
	var count = 0;
	for (var i = 0; i < ds_grid_height(loc_data); i++) {
		var key = ds_grid_get(loc_data, 0, i);
		if ds_map_exists(global.Translations, key)
			continue;
		var line = h + count;
		count++;
		ds_map_set(global.Translations, key, line)
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
			log_info(line)
		}
	}	
}
