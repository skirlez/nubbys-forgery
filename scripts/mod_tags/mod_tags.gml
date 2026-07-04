function tags_create() {
	return array_create_ext(mod_resources.size, function () { 
		return ds_map_create();
	})
}
function tags_destroy(tags) {
	for (var type = 0; type < mod_resources.size; type++) {
		ds_map_destroy(tags[type]);
	}
}
function tags_clear(tags) {
	for (var type = 0; type < mod_resources.size; type++) {
		ds_map_clear(tags[type])
	}
}


global.tags = tags_create()


function mod_get_resources_with_tag(type, tag) {
	var map = global.tags[type]
	if !ds_map_exists(map, tag)
		return [];
	return ds_map_find_value(map, tag)
}

function add_to_tag(tag, type, struct) {
	var arr
	if !ds_map_exists(global.tags[type], tag) {
		arr = []
		ds_map_set(global.tags[type], tag, arr)
	}
	else 
		arr = ds_map_find_value(global.tags[type], tag)
	array_push(arr, struct)
}