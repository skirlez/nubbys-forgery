local patch = (require "g3man").patch

patch('gml_Object_obj_Perk_MysteryBox_Create_0', function(t)
	t:write(t:last_line(), [[
		add_items_to_mystery_box_perk()
	]])
end)
