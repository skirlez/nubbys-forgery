function mod_register_perk(perk, perk_id, wod = global.cmod) {
	static perk_contract = {
		display_name : "",
		description : "",
		sprite : agi("obj_empty"),
		game_event : "",
		tier : 0,
		type : 0,
		pool : 0,
		trigger_fx_color : int64(0),
		additional_info_type : 0,
		on_create : global.empty_method,
		on_trigger : global.empty_method,
	}
	
	static optional_variables = {
		manage_own_trigger : false,
		display_name_args : [],
		description_args : ["\n"]
	}
	var success = register_generic(mod_resources.perk, perk, perk_id, perk_contract, optional_variables, tautology, "Perk", "a perk", wod.perks, wod)
	if !success
		return undefined
	return perk;
}

// called from gml_Object_obj_PerkMGMT_Create_0
function register_perks_for_gameplay() {
	free_all_allocated_objects(mod_resources.perk)
	clear_index_assignments(mod_resources.perk)
		
	var perk_ids = bimap_lefts_array(global.registry[mod_resources.perk])
	for (var i = 0; i < array_length(perk_ids); i++) {			
		var perk = bimap_get_right(global.registry[mod_resources.perk], perk_ids[i])
			
		var perk_index = array_length(agi("obj_PerkMGMT").PerkID)

		var obj = allocate_object(mod_resources.perk, perk)
		object_set_sprite(obj, perk.sprite)
			
		agi("scr_Init_Perk")(perk_index,
			script_execute_ext(agi("scr_Text"), array_concat([perk.display_name], perk.display_name_args)),
			obj,
			perk.game_event, 
			perk.tier, 
			perk.type, 
			perk.pool,
			perk.trigger_fx_color, 
			perk.additional_info_type,
			script_execute_ext(agi("scr_Text"), array_concat([perk.description], perk.description_args)))
			
		assign_index_to_resource(mod_resources.perk, perk, perk_index)
		log_info($"Perk {perk_ids[i]} has been indexed: {perk_index}")
	}
}


