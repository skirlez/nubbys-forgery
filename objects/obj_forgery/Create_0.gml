global.empty_method = method(self, empty_function)
global.mod_id_to_mod_map = ds_map_create();
global.logging_socket = network_create_socket(network_socket_udp)
global.mods_directory = "g3man_applied_profile";

initialize_catspeak();

global.cmod = noone;

global.sound_count = 0;
while (audio_exists(global.sound_count))
	global.sound_count++;
global.sprite_count = 0;
while (sprite_exists(global.sprite_count))
	global.sprite_count++;


// Unfortunately this must be hardcoded for now...
// Nubby resources are each created in their own object, that only exists during gameplay.
// The only way to find how long the resource arrays are would be is to create them and check,
// and I don't want to. But actually that may be worth looking into.
global.last_indices = array_create(mod_resources.size)
global.last_indices[mod_resources.item] = 183
global.last_indices[mod_resources.perk] = 32
global.last_indices[mod_resources.supervisor] = 11

log_info("****************\Forgery start****************")
read_all_mods()

if is_console_and_devmode_enabled()
	alarm[0] = 1

// prevents crash with devmode since this is for some reason set in step of an object and not in create
global.CursTar = -1

run_delayed = [];
function add_to_run_delayed(frames, args, func, wod) {
	array_push(run_delayed, { time : frames, args : args, func : func, mod_of_origin : wod })
}
function remove_mod_from_run_delayed(wod) {
	var len = array_length(run_delayed);
	for (var i = 0; i < len; i++) {
		if run_delayed[i].mod_of_origin == wod {
			array_delete(run_delayed, i, 1)
			len--;
			i--;
		}
	}
}
function iterate_run_delayed() {
	var len = array_length(run_delayed);
	for (var i = 0; i < len; i++) {
		var struct = run_delayed[i];
		struct.time--;
		if struct.time <= 0 {
			struct.func(struct.args);
			array_delete(run_delayed, i, 1)
			len--;
			i--;
		}
	}
}

