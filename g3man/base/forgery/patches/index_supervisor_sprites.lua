
local targets = 'gml_Object_obj_TonyMGMT_Create_0'
patch(targets, function(t)
	t:write(t:get_end(), 'register_supervisors_sprites_for_gameplay()')
end)
