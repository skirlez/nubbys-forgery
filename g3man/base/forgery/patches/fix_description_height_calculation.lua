local patch = (require "g3man").patch
patch(
{
	target = {
	    -- technically can be applied to more code files
		-- not doing it until anyone complains though
		'gml_Object_obj_ItemMGMT_Draw_64',
	    'gml_Object_obj_PerkMGMT_Draw_64',
	}
},
function(t)
	local i
	i = t:find_line_with(1, 'DrawDescY = clamp(DrawDescY, string_height_ext')
	t:write_replace_substring(i, 'string_height_ext', [[
		forgery_string_height_ext_desc_fixed
	]])
	i = t:find_line_with(1, 'var _Lines = 6 + ((string_height_ext')
	t:write_replace_substring(i, 'string_height_ext', [[
		forgery_string_height_ext_desc_fixed
	]])
end)
