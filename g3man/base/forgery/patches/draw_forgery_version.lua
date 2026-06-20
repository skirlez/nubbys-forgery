local patch = (require "g3man").patch
patch('gml_Object_obj_BuildInfo_Draw_0', function(t)
	local i = t:find_line_with(1, 
		'scr_Text("gameversion"'
	)
	t:write_before(i, [[
		draw_text(16, 1054 - 56, get_nf_version_string());
		draw_text(16, 1054 - 28, get_nf_loaded_string());
	]])
end)
