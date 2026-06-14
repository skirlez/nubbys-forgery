-- Load forgery autosave, passing in old data to fix indices

local targets = 'gml_GlobalScript_scr_Load_AutoSave'
patch(targets, function(t)
	local i = t:find_line_with(1, 'json_parse(_LoadString)')
	t:write(i,
		'load_forgery_autosave(_LoadData)'
	)
end)

-- End of the function. Save forgery's additional save file. Additionally provide the base save string, for hashing.
local targets = 'gml_GlobalScript_scr_Save_AutoSave'
patch(targets, function(t)
	local i = t:find_line_with_reverse(t:last_line(),
		'buffer_delete(_Buffer)'
	)
	t:write(i,
		'save_forgery_autosave(_SaveString)'
	)
end)
