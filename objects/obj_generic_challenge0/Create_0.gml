// This object is cloned by the merger script a lot, but all of them run the same event code.

// We need to determine at runtime what number object we are:
allocated_id = real(string_digits(object_get_name(object_index)))

// These objects are allocated to different items.
// Get the challenge this object is allocated to
challenge = get_resource_allocated_to_object(mod_resources.challenge, allocated_id)
// This challenge struct determines how this object behaves.


// Get the challenge's index ID. Though none of them use it. But might as well get it,
// as perks and items do.
SVID = bimap_get_left(global.index_registry[mod_resources.challenge], challenge)

// Get its string ID, for logging
string_id = bimap_get_left(global.registry[mod_resources.challenge], challenge)

mod_of_origin = ds_map_find_value(global.mod_id_to_mod_map, mod_identifier_get_namespace(string_id))


sprite_index = challenge.oval_sprite

// this is also how the base game checks this. 
// i'm abstracting this away into a parameter for end users because it's stupid
// and i hope in the future it can be changed
var is_loading_from_autosave = (file_exists("NUBBY_AutoSave_F.save"))

global.cmod = mod_of_origin;
try {
	execute(challenge.on_create, [id, is_loading_from_autosave], id)
}
catch (e) {
	log_error($"Challenge manager {string_id} errored on creation: {pretty_error(e)}")
	// TODO leave game?
}

