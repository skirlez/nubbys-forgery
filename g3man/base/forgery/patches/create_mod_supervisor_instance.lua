local targets = 'gml_Object_obj_LvlMGMT_Other_4'

patch(targets, function(t)
	t:write(t:last_line(), 'create_mod_supervisor_object(SVID)')
end)
