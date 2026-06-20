local patch = (require "g3man").patch

patch('gml_GlobalScript_scr_InitChallengeManager', function(t)
    local i = t:find_line_with(1, 'function scr_InitChallengeManager')
    i = t:find_line_with(i, 'switch (arg0)')

	t:write(i + 1, [[
		default:
			create_mod_challenge_object(arg0, arg1)
			break
	]])
end)
