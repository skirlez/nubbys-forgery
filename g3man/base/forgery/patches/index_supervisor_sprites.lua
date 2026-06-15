local patch = (require "g3man").patch

patch('gml_Object_obj_TonyMGMT_Create_0', function(t)
	t:write(t:last_line(), 'register_supervisors_sprites_for_gameplay()')
end)
