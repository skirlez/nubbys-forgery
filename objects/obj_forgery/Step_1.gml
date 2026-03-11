iterate_run_delayed()
if !keyboard_check_pressed(vk_backspace)
	exit;
var arr = agi("obj_ItemMGMT").ItemID
for (var i = 0; i < array_length(arr); i++) {
	log_info($"{i}: {arr[i]}")
}
