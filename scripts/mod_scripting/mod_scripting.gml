
function initialize_catspeak() {
	catspeak_force_init();
	// One of the goals of this project is to not limit what mods can do.
	// The worst thing enabling this can do is allow mods to delete saved scores,
	// but since scores are saved in a different folder, and GameMaker has a sandboxed filesystem,
	// your base game scores cannot be touched.
	
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

function execute(code, args = undefined) {
	if !is_array(args)
		args = [args]
	return catspeak_execute_ext(code, catspeak_globals(code), args)
}
