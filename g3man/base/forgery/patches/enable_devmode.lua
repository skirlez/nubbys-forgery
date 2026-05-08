patch('gml_Object_obj_Debug_Create_0', function(t)
	t:write(t:get_end(),
		'DevMode = is_console_and_devmode_enabled()'
	)
end)
