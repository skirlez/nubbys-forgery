local patch = (require "g3man").patch

patch('gml_Object_obj_LvlMGMT_Other_4', function(t)
	t:write(t:last_line(), 'create_mod_supervisor_object(SVID)')
end)
