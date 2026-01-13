if item.on_round_init == global.empty_method
	return;
global.cmod = mod_of_origin;
try {
	execute(item.on_round_init, id, id)
}
catch (e) {
	log_error($"Item {string_id} errored on round initialization: {pretty_error(e)}")
}