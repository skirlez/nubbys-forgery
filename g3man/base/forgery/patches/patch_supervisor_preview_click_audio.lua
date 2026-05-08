
local targets = 'gml_Object_obj_SupervisorPreviewMAIN_Step_0'

patch(targets, function(t)
	local i = t:find_line_with(1, 'switch (SVPreviewVal)')
	t:write_before(i,
		'on_supervisor_preview_choose_clicked_audio()'
	)
end)
