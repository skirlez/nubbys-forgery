if item.manage_own_trigger == true {
	global.cmod = mod_of_origin;
	try {
		execute(item.on_trigger, id, id)
	}
	catch (e) {
		log_error($"Item {string_id} errored on trigger: {pretty_error(e)}")
	}
	return;	
}
if item.food {
	switch (ds_list_find_value(ItemQueue, 0)) {
		case 1:
			if ItemLevel == 0
				agi("scr_FoodEffect")(MyItemID)
			else
				agi("scr_UpgrFoodEffect")(MyItemID)
			instance_destroy()
		    break
	}
}
else {
	if DisableItem == false && global.GameMode == 1 {
		if ItemLevel == 0
			agi("scr_L1_ItemEffect")(MyItemID)
		else
			agi("scr_L2_ItemEffect")(MyItemID)
		agi("scr_FX_ItemFire")(agi("au_ItemFireGrl"));
		agi("scr_TrackFire")();
		agi("scr_PositionalEv")();
	}
	agi("scr_ItemQueue")();
}