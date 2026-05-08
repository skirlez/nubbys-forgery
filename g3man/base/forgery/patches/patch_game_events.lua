-- Trigger game event callbacks
local targets = 'gml_GlobalScript_scr_GameEv'
patch(targets, function(t)
	local i = t:find_line_with(1, '{')
	t:write(i, 'on_game_event(arg0, argument1)')
end)

-- Make it so modders can pass in whatever trigger condition they want
local targets = 'gml_GlobalScript_scr_GameEv'
patch(targets, function(t)
	local i = t:find_line_with(1, 'switch (arg0)')
	t:write(i + 1, [[
		default:
	    scr_ItemMetaOrder(arg0)
	    scr_PerkMetaOrder(arg0)
	    scr_StatusMetaOrder(arg0)
	    break;
	]])
end)
