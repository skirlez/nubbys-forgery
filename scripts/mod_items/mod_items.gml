// For catspeak
function mod_register_item(item, item_id, wod = global.cmod) {
	if !mod_is_id_component_valid(item_id) {
		log_error($"Mod {wod.mod_id} tried to register an item with invalid ID {item_id}")
		return;
	}
	if bimap_right_exists(global.registry[mod_resources.item], item) {
		var current_id = bimap_get_left(global.registry[mod_resources.item], item)
		log_error($"Mod {wod.mod_id} tried to register an item struct with ID {item_id},"
			+ $" but this struct has already been registered prior to {current_id}! Each struct registered must be unique.")	
		return;
	}
	
	static item_contract = {
		display_name : "",
		description : "",
		game_event : "",
		alt_game_event : "",
		sprite : agi("spr_empty"),
		level : 0,
		tier : 0,
		augment : "",
		effect : "",
		pool : 0,
		offset_price : 0,
		pair_id : "",
		on_create : global.empty_method,
		on_trigger : global.empty_method,
	}

	
	var compliance = get_struct_compliance_with_contract(item, item_contract)
	if array_length(compliance.missing) > 0 || array_length(compliance.mismatched_types) > 0 {
		log_error($"Item {item_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_compliance_error_text(item, item_contract, compliance)
			+ "\nThe item is not registered.")
		return;
	}
	
	static optional_variables = {
		on_step : global.empty_method,
		on_round_init : global.empty_method,
		manage_own_trigger : false,
		food_crumb_colors : [c_white, c_white],
		food : false,
		odds_weight_early : 5,
		odds_weight_mid : 5,
		odds_weight_end : 5,
	}
	var compliance = get_struct_compliance_with_contract(item, optional_variables)
	if array_length(compliance.mismatched_types) > 0 {
		compliance.missing = [];
		log_error($"Item {item_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_compliance_error_text(item, item_contract, compliance)
			+ "\nThe item is not registered.")
		return;
	}

	initialize_missing(item, optional_variables)
	
	if array_length(item.food_crumb_colors != 2) || !is_numeric(item.food_crumb_colors[0]) || !is_numeric(item.food_crumb_colors[1]) {
		log_error($"Item {item_id} from {wod.mod_id} has bad variables!\n"
		+ "If you are registering a food item, the \"food_crumb_colors\" array MUST have exactly two color values.")
		return;
	}
	
	var full_id = $"{wod.mod_id}:{item_id}"
	
	bimap_set(global.registry[mod_resources.item], full_id, item)
	array_push(wod.items, item)
	
	log_info($"Item {full_id} registered {item.game_event == "Eat" ? "(as food)" : ""}");
	return item;
}




// called from gml_Object_obj_ItemMGMT_Create_0
function register_items_for_gameplay() {
	free_all_allocated_objects(mod_resources.item)
	clear_index_assignments(mod_resources.item)
	
	var item_ids = bimap_lefts_array(global.registry[mod_resources.item])
	for (var i = 0; i < array_length(item_ids); i++) {			
		var item = bimap_get_right(global.registry[mod_resources.item], item_ids[i])
			
		var item_index = array_length(agi("obj_ItemMGMT").ItemID)

		var obj = allocate_object(mod_resources.item, item)
			
		object_set_sprite(obj, item.sprite)
		agi("scr_Init_Item")(item_index,
			agi("scr_Text")(item.display_name),
			obj,
			item.level,
			item.food,
			item.tier, 
			item.augment,
			item.effect, 
			item.pool, 
			item.offset_price, 
			item.pair_id, 
			item.game_event, 
			item.alt_game_event,
			agi("scr_Text")(item.description, "\n"))
			
		agi("scr_Init_ItemExt")(item_index, 
			item.odds_weight_early, item.odds_weight_mid, item.odds_weight_end)
			
		assign_index_to_resource(mod_resources.item, item, item_index)
			
		log_info($"Item {item_ids[i]} has been indexed: {item_index}")
	}
	
	// we need to pass over this array after all items have been registered
	// so we can then resolve the temporary upgrade item ID we put in and replace it with
	// an index ID
	var item_pair_arr = agi("obj_ItemMGMT").ItemPair
	for (var i = 0; i < array_length(item_pair_arr); i++) {
		if !is_string(item_pair_arr[i])
			continue;
		var pair_id = item_pair_arr[i]
		if !bimap_left_exists(global.registry[mod_resources.item], pair_id) {
			var this_item = bimap_get_right(global.index_registry[mod_resources.item], i)
			var this_item_id = bimap_get_left(global.registry[mod_resources.item], this_item);
			
			log_error($"Item {this_item_id} has {pair_id} set"
				+ " as its pair, but it does not exist! Setting it to Pants")
			item_pair_arr[i] = 0;
			continue;
		}
		
		item_pair_arr[i] = mod_registries_exchange(global.registry, global.index_registry, mod_resources.item, pair_id)
	}
}

// called from gml_GlobalScript_scr_L1_ItemEffect and gml_GlobalScript_scr_L2_ItemEffect
function forgery_modded_item_effect(index) {
	var item = mod_registry_get_right(global.index_registry, mod_resources.item, index)
	if item == undefined {
		log_warn($"Game tried to perform item effect of item with index {index}, which does not exist")
		return;	
	}
	var string_id = mod_registry_get_left(global.registry, mod_resources.item, item)
	var previous_mod = global.cmod
	global.cmod = ds_map_find_value(global.mod_id_to_mod_map, mod_identifier_get_namespace(string_id))
	try {
		execute(item.on_trigger, id, id)
	}
	catch (e) {
		log_error($"Item {string_id} errored on trigger: {pretty_error(e)}")
	}
	global.cmod = previous_mod;
}
