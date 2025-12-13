
function initialize_catspeak() {
	catspeak_force_init();

	// (This causes an Ubuntu crash. IDK why. The real game is on proton on steam anyways so who cares.)
	Catspeak.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
	
	expose_constants(Catspeak.interface)
}

function expose_constants(interface) {
	interface.exposeConstant("mod_resource_item", mod_resources.item)
	interface.exposeConstant("mod_resource_perk", mod_resources.perk)
	interface.exposeConstant("mod_resource_supervisor", mod_resources.supervisor)
}


function compile_code_file(path) {
	var type = mod_get_code_type(path)
	var buffer = buffer_load(path)
	var ir;
	var main;
	if type == code_file_types.catspeak {
		ir = Catspeak.parse(buffer);
		main = Catspeak.compile(ir);
	}

	buffer_delete(buffer)
	return main;
}

function execute(code, args = undefined, this = catspeak_globals(code)) {
	if !is_array(args)
		args = [args]
	return catspeak_execute_ext(code, this, args)
}
