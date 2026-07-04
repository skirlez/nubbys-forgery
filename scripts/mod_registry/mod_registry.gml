enum mod_resources {
	item,
	perk,
	supervisor,
	challenge,
	size,
}
global.resource_names = ["item", "perk", "supervisor", "challenge"]

function registry_create() {
	return array_create_ext(mod_resources.size, function () { 
		return bimap_create();
	})
}

global.registry = registry_create();

function registry_destroy(registry) {
	for (var type = 0; type < mod_resources.size; type++) {
		bimap_destroy(registry[type]);
	}
}
function registry_clear(registry) {
	for (var type = 0; type < mod_resources.size; type++) {
		registry_clear_type(registry, type)
	}
}



function mod_get_resource_index_from_sid(type, string_id) {
	return mod_registries_exchange(global.registry, global.index_registry, type, string_id)
}
function mod_get_resource_sid_from_index(type, index) {
	return mod_registries_exchange(global.index_registry, global.registry, type, index)
}

function registry_clear_type(registry, type) {
	bimap_clear(registry[type]);
}
function mod_registry_left_exists(registry, type, left) {
	return bimap_left_exists(registry[type], left)
}
function mod_registry_right_exists(registry, type, right) {
	return bimap_right_exists(registry[type], right)
}

function mod_registry_get_left(registry, type, right) {
	return bimap_get_left(registry[type], right)
}
function mod_registry_get_right(registry, type, left) {
	return bimap_get_right(registry[type], left)
}
function mod_registries_exchange(from, to, type, left) {
	var right = bimap_get_right(from[type], left)
	return bimap_get_left(to[type], right)
}


function register_generic(type, res, res_id, res_contract, res_optional_contract, extra_checks, res_name, res_a_name, wod_array, wod = global.cmod) {
	if !mod_is_id_component_valid(res_id) {
		log_error($"Mod {wod.mod_id} tried to register {res_a_name} with invalid ID {res_id}")
		return false;
	}
	if bimap_right_exists(global.registry[type], res) {
		var current_id = bimap_get_left(global.registry[type], res)
		log_error($"Mod {wod.mod_id} tried to register {res_a_name} struct with ID {res_id},"
			+ $" but this struct has already been registered prior to {current_id}! Each struct registered must be unique.")	
		return false;
	}

	
	var compliance = get_struct_compliance_with_contract(res, res_contract)
	if array_length(compliance.missing) > 0 || array_length(compliance.mismatched_types) > 0 {
		log_error($"{res_name} {res_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_compliance_error_text(res, res_contract, compliance)
			+ $"\n{res_name} is not registered.")
		return false;
	}
	
	// all resources have tags
	res_optional_contract.tags = []
	
	var optional_compliance = get_struct_compliance_with_contract(res, res_optional_contract)
	if array_length(optional_compliance.mismatched_types) > 0 {
		optional_compliance.missing = [];
		log_error($"{res_name} {res_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_compliance_error_text(res, res_optional_contract, optional_compliance)
			+ $"\n{res_name} is not registered.")
		return false;
	}
	initialize_missing(res, res_optional_contract)
	
	if (!extra_checks(res, res_id, wod))
		return false;
	
	var full_id = $"{wod.mod_id}:{res_id}"
	
	bimap_set(global.registry[type], full_id, res)
	for (var i = 0; i < array_length(res.tags); i++) {
		add_to_tag(res.tags[i], type, res)
	}
	array_push(wod_array, res)
	
	log_info($"{res_name} {full_id} registered");
	return true;
}