local patch = (require "g3man").patch

patch('gml_Object_obj_ChallengesMGMT_Create_0', function(t)
  local i = t:find_line_with(1, 'ChallengeTN[10] = spr_CHTN_NT1')
  t:write(i, 'if false {')
  i = t:find_line_with(i, 'ChallengeTN[14] = spr_CHTN_NT5')
  t:write(i, '}')

  t:write(t:last_line(), [[
    NubbyTrialsTN[0] = spr_CHTN_NT1;
    NubbyTrialsTN[1] = spr_CHTN_NT2;
    NubbyTrialsTN[2] = spr_CHTN_NT3;
    NubbyTrialsTN[3] = spr_CHTN_NT4;
    NubbyTrialsTN[4] = spr_CHTN_NT5;
  ]])
end)


patch('gml_Object_obj_ChallengesMGMT_Draw_0', function(t)
  local i = t:find_line_with(1, 'ChallengeTN[10 + NubbyTrialsPage]')
  t:write_replace_substring(i, 'ChallengeTN[10 + NubbyTrialsPage]', 'NubbyTrialsTN[NubbyTrialsPage]')
end)


patch('gml_Object_obj_CHGoBtn_Alarm_1', function(t)
  local i

  i = t:find_line_with(1, 'ChallengeTN[10 + obj_ChallengesMGMT.NubbyTrialsPage]')
  t:write_replace_substring(i, 'ChallengeTN[10 + obj_ChallengesMGMT.NubbyTrialsPage]', 'NubbyTrialsTN[obj_ChallengesMGMT.NubbyTrialsPage]')

  i = t:find_line_with(1, 'if (obj_ChallengesMGMT.ChallengeOrder[obj_ChallengesMGMT.ChallengePage] < 10)')
  t:write_replace_substring(i, '< 10', '!= 10')
end)
