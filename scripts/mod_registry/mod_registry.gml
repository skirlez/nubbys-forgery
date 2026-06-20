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



var item = mod_registry_get_right(global.registry, mod_resources.item, "mod_id:item_name")
var index = mod_registry_get_left(global.index_registry, mod_resources.item, item)

var index = mod_registries_exchange(global.registry, global.index_registry, mod_resources.item, "mod_id:item_name")
var found = false;
with (obj_ItemParent) {
	if (MyItemID == index) {
		found = true;
		break;
	}
}

function get_item_index_from_name(str) {
	return mod_registries_exchange	
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