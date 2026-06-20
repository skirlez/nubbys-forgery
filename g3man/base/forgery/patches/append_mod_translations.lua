local patch = (require "g3man").patch

-- Add mod translation keys
patch({ target = 'gml_GlobalScript_scr_InitTranslations', fail_fast=false }, function(t)
	local i = 0
    while true do
        i = t:find_line_with(i + 1, 'global.Translations = ds_map_create()')
		if (i == -1) then break end
        t:write(i, 'append_mod_translations()')
	end
end)
