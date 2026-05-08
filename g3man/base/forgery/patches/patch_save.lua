-- Save "Highscore" save for forgery resources
local targets = 'gml_Object_obj_Saver_Alarm_0'
patch(targets, function(t)
	local i = t:find_line_with(1, 'case "Highscore"')
	i = t:find_line_with(i, 'break')
	t:write_before(i, 'save_forgery_highscore()')
end)


-- Save "Progression" save for forgery resources
local targets = 'gml_Object_obj_Saver_Alarm_0'
patch(targets, function(t)
	local i = t:find_line_with(1, 'case "Progression"')
	i = t:find_line_with(i, 'break')
	t:write_before(i, 'save_forgery_progression()')
end)

-- Load "Highscore" save
local targets = 'gml_Object_obj_Loader_Alarm_0'
patch(targets, function(t)
	local i = t:find_line_with(1, 'case "Highscore"')
	i = t:find_line_with(i, 'break')
	t:write_before(i, 'load_forgery_highscore()')
end)

-- Load "Progression" save
local targets = 'gml_Object_obj_Loader_Alarm_0'
patch(targets, function(t)
	local i = t:find_line_with(1, 'case "Progression"')
	i = t:find_line_with(i, 'break')
	t:write_before(i, 'load_forgery_progression()')
end)
