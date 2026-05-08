
patch('gml_Object_obj_LoadGameBtn_Create_0', function(t)
	t:write(t:get_end(), [[
		missing_resources = load_button_is_save_loadable()
		mod_message = noone
	]])
end)



patch('gml_Object_obj_LoadGameBtn_Step_0', function(t)
	t:write_before(1, [[
		if instance_exists(mod_message) {
			mask_index = spr_empty
		}
		else
			mask_index = sprite_index
	]])
	local i = t:find_line_with(1, 'if (obj_LvlMGMT.GameFader == 0)')
	t:write_before(i,
	[[
		if (array_length(missing_resources) > 0) {
			mod_message = load_button_create_message(missing_resources)
		}
		else
	]])
end)
