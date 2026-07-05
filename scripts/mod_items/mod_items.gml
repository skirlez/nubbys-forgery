function mod_register_item(item, item_id, wod = global.cmod) {
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
	static optional_variables = {
		on_step : global.empty_method,
		on_round_init : global.empty_method,
		manage_own_trigger : false,
		food_crumb_colors : [c_white, c_white],
		food : false,
		odds_weight_early : 5,
		odds_weight_mid : 5,
		odds_weight_end : 5,
		display_name_args : [],
		description_args : ["\n"],
	}
	var success = register_generic(mod_resources.item, item, item_id, item_contract, optional_variables, function(res, res_id, wod) {
		if array_length(res.food_crumb_colors != 2) || !is_numeric(res.food_crumb_colors[0]) || !is_numeric(res.food_crumb_colors[1]) {
			log_error($"Item {res_id} from {wod.mod_id} has bad variables!\n"
				+ "If you are registering a food item, the \"food_crumb_colors\" array MUST have exactly two color values.")
			return false;
		}
		return true;
	}, "Item", "an item", wod.items, wod)
	if !success
		return undefined
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
		var plus = (item.level == 2 ? "+" : "");
		agi("scr_Init_Item")(item_index,
			script_execute_ext(agi("scr_Text"), array_concat([(item.display_name)], item.display_name_args)) + plus,
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
			script_execute_ext(agi("scr_Text"), array_concat([item.description], item.description_args)))
			
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
		if (!item.manage_own_trigger && item.food) {
			agi("obj_ItemMGMT").RecentEatenFoodDisp = agi("obj_ItemMGMT").ItemID[index];
			agi("obj_ItemMGMT").RecentEatenFoodDispID = index;
			agi("obj_ItemMGMT").RecentEatenFood = index;	
		}
	}
	catch (e) {
		log_error($"Item {string_id} errored on trigger: {pretty_error(e)}")
	}
	global.cmod = previous_mod;
}

function forgery_get_item_desc_line_amount_fixed(desc, max_width) {
	var font = draw_get_font();
	return 6 + ((agi("scribble")(desc)
		.starting_format(font_get_name(font), c_white)
		.line_spacing(26, 26)
		.wrap(max_width)
		.get_height()) div 26);
}
// called from gml_Object_obj_Perk_MysteryBox_Create_0
function add_items_to_mystery_box_perk() {
	var items = mod_get_resources_with_tag(mod_resources.item, "forgery:mystery_box_friendly")
	for (var i = 0; i < array_length(items); i++) {
		var index = mod_registry_get_left(global.index_registry, mod_resources.item, items[i])
		log_info($"adding index: {index}")
		array_push(MystBoxPool, index)
	}
}