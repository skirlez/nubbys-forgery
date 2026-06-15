local patch = (require "g3man").patch
patch('gml_Object_obj_Debug_Create_0', function(t)
	t:write(t:last_line(),
		'DevMode = is_console_and_devmode_enabled()'
	)
end)
