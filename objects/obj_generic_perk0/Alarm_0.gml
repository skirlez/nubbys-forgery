if perk.manage_own_trigger {
	global.cmod = mod_of_origin;
	try {
		execute(perk.on_trigger, id, id)
	}
	catch (e) {
		log_error($"Perk {string_id} errored on trigger: {pretty_error(e)}")
	}
	return;	
}

if (DisablePerk == false && global.GameMode == 1) {
	try {
		execute(perk.on_trigger, id, id)
	}
	catch (e) {
		log_error($"Perk {string_id} errored on trigger: {pretty_error(e)}")
	}
	agi("scr_FX_PerkFire")();
}
agi("scr_PerkQueue")();
