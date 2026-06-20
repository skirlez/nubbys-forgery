local patch = (require "g3man").patch
-- Instantiate the modloader object
local targets = 'gml_Object_obj_Debug_Create_0'
patch(targets, function(t)
	t:write(1,
		'instance_create_depth(0, 0, 0, obj_forgery)'
	)
end)
