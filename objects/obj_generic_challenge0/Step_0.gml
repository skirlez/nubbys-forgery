var challenge_desc = agi("obj_ChallengeDesc")
if (global.CursTar == id) {
	if (!instance_exists(challenge_desc))
		var _CHDesc = instance_create_depth(x, y, depth - 1, challenge_desc);
	
	if (instance_exists(challenge_desc)) {
		challenge_desc.ChTarDesc = id;
		challenge_desc.DrawChDesc = agi("obj_LvlMGMT").ChDesc;
		challenge_desc.DrawChName = agi("obj_LvlMGMT").ChallengeName;
		challenge_desc.DrawDescX = agi("obj_Cursor").x;
		challenge_desc.DrawDescY = agi("obj_Cursor").y;
	}
}
else if (instance_exists(challenge_desc))
	challenge_desc.ChTarDesc = -1;

