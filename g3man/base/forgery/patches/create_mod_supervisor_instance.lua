local targets = 'gml_Object_obj_LvlMGMT_Other_4'

patch(targets, function(t)
	t:write(t:get_end(), 'create_mod_supervisor_object(SVID)')
end)
