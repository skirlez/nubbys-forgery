-- Add mod translation keys
local targets = 'gml_GlobalScript_scr_InitTranslations'
patch(targets, function(t)
	local i = 0
    while true do
        i = t:find_line_with(i + 1, 'global.Translations = ds_map_create()')
		if (i == -1) then break end
        t:write(i, 'append_mod_translations()')
	end
end)
