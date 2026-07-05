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
	local i = t:find_line_with(1, 'var _Lines = 6 + ((string_height_ext(DrawDesc, 26, _DescWid - 15) - 56) div 26)')
	t:write_replace(i, [[
		var _Lines = 6 + ((string_height_scribble_ext(DrawDesc, _DescWid - 15) - 56) div 26)
	]])
end)
