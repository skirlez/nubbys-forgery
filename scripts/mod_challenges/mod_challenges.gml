function mod_register_challenge(challenge, challenge_id, wod = global.cmod) {
	static challenge_contract = {
		display_name : "",
		description : "",
		sprite : agi("spr_empty"),
		oval_sprite : agi("spr_empty"),
		on_create : global.empty_method,
		
	}
	static optional_variables = {
		display_name_args : ["\""],
		description_args : ["\n"],	
	}
	
	var success = register_generic(mod_resources.challenge, challenge, challenge_id, challenge_contract, optional_variables, tautology, 
		"Challenge", "a challenge", wod.challenges, wod)
	if !success
		return undefined
	
	var full_id = $"{wod.mod_id}:{challenge_id}"
	// Challenges must be indexed immediately. See matching line in the supervisor's file
	var index = global.last_indices[mod_resources.challenge] 
		+ bimap_size(global.index_registry[mod_resources.challenge])
		+ 1
	index_challenge(challenge, full_id, index)
	return challenge;
}


// Called from gml_Object_obj_ChallengesMGMT_Create_0
function index_challenges_for_selection() {
	var challenge_indices = bimap_lefts_array(global.index_registry[mod_resources.challenge])
	for (var i = 0; i < array_length(challenge_indices); i++) {
		var index = challenge_indices[i]
		with (agi("obj_challengeMGMT")) {
			var challenge = bimap_get_right(global.index_registry[mod_resources.challenge], index)
			
			ChallengeID[index] = script_execute_ext(agi("scr_Text"), 
					array_concat([challenge.display_name], challenge.display_name_args))
			ChallengeDesc[index] = script_execute_ext(agi("scr_Text"), 
					array_concat([challenge.description], challenge.description_args))
			ChallengeTN[index] = challenge.sprite;
			ChallengeOrder[index] = index
			
			var string_id = mod_registries_exchange(global.index_registry, global.registry, mod_resources.challenge, index)
			log_info($"Challenge {string_id} has been indexed for selection screen: {index}")
				
		}
	}
}
function index_challenge(challenge, string_id, index) {
	var obj = allocate_object(mod_resources.challenge, challenge)
	// TODO. use a map for this.
	challenge.__object = obj;
	assign_index_to_resource(mod_resources.challenge, challenge, index)
	
	// these are later overriden by your progress and highscore save,
	// if you have any.
	with (agi("obj_GAME")) {
		BeatChallenge[index] = 0
		ChWins[index] = 0
		ChallengeHS[index] = 0;
	}
	
	log_info($"Challenge {string_id} has been indexed: {index}")
}

// Called from gml_GlobalScript_scr_InitChallengeManager
function create_mod_challenge_object(index_id, lvlmgmt) {
	index_id = real(index_id); // SVID is sometimes a string
	var challenge = bimap_get_right(global.index_registry[mod_resources.challenge], index_id);
	if challenge == undefined
		return; // Vanilla challenge

	var obj = challenge.__object;
	lvlmgmt.ChManager = instance_create_layer(1446, 238, "GAME", obj);
}


