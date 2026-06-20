local patch = (require "g3man").patch

-- This patch modifies both of the scripts above, so their default case goes to modded items
patch(
{
	target={ 'gml_GlobalScript_scr_L1_ItemEffect', 'gml_GlobalScript_scr_L2_ItemEffect', 'gml_GlobalScript_scr_FoodEffect',
            'gml_GlobalScript_scr_UpgrFoodEffect' },
},
function(t)
	local i = t:find_line_with(1, 'switch (arg0)')
	t:write(i + 1, [[
	default:
		forgery_modded_item_effect(arg0)
		break;
	]])
end)
