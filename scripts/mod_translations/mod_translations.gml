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
	switch (global.Localization) {
		case 0:
			return "en"
		case 1:
			return "pt-BR";
	}
}

// Called after scr_InitTranslations()
function append_mod_translations() {
	var lang = get_current_language_id();
	// global.Translations is a ds_map, mapping keys to rows on the csv
	// global.LocData is the base game csv ds_grid
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i];
		log_info($"Appending translations from {wod.mod_id}")
		if ds_map_exists(wod.translations, lang) {
			append_translations(ds_map_find_value(wod.translations, lang))
			if lang == "en"
				continue;
		}
			
		// append english keys as a fallback
		if !ds_map_exists(wod.translations, "en")
			continue;
		append_translations(ds_map_find_value(wod.translations, "en"))
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

function append_translations(loc_data) {
	// TODO error handling if the mod csv isn't two values per row. Check here and log
	var h = ds_grid_height(global.LocData)
	ds_grid_resize(global.LocData, ds_grid_width(global.LocData), 
		h + count_keys_not_already_added(loc_data))
			
	for (var i = 0; i < ds_grid_height(loc_data); i++) {
		var key = ds_grid_get(loc_data, 0, i);
		if ds_map_exists(global.Translations, key)
			continue;
		var line = h + i;
		
		ds_map_set(global.Translations, key, line)
		ds_grid_set(global.LocData, 0, line, key)
		if global.Localization == 0 {
			ds_grid_set(global.LocData, 1, line, ds_grid_get(loc_data, 1, i))
			ds_grid_set(global.LocData, 2, line, "")
		}
		else {
			// I'm not sure what the idea is here
			ds_grid_set(global.LocData, 1, line, "")
			ds_grid_set(global.LocData, 2, line, ds_grid_get(loc_data, 1, i))
		}
	}	
}
