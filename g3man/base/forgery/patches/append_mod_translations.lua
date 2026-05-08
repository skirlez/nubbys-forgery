-- Add mod translation keys
local targets = 'gml_GlobalScript_scr_InitTranslations'
patch(targets, function(t)
	t:write(t:find_line_with(1, 'global.Translations ='), 
	[[
		append_mod_translations()
	]])
end)
