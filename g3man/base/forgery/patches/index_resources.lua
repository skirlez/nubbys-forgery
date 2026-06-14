
local targets = {
	'gml_Object_obj_ItemMGMT_Create_0',
	'gml_Object_obj_PerkMGMT_Create_0',
	'gml_Object_obj_SupervisorMGMT_Create_0',
	'gml_Object_obj_ChallengesMGMT_Create_0'
}
FunctionToCall = {
	gml_Object_obj_ItemMGMT_Create_0 = 'register_items_for_gameplay',
	gml_Object_obj_PerkMGMT_Create_0 = 'register_perks_for_gameplay',
	gml_Object_obj_SupervisorMGMT_Create_0 = 'index_supervisors_for_selection',
	gml_Object_obj_ChallengesMGMT_Create_0 = 'index_challenges_for_selection'
}


patch(targets, function(t)
	local func = FunctionToCall[t.name]
	t:write(t:last_line(), func .. '()')
end)
