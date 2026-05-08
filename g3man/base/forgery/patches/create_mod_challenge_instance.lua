local targets = 'gml_GlobalScript_scr_InitChallengeManager'

patch(targets, function(t)
	t:find_line_with(1, 'function scr_InitChallengeManager')
	t:write(t:get_end(), 'create_mod_challenge_object(arg0, arg1)')
end)
