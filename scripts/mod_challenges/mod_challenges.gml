// For catspeak
function mod_register_challenge(challenge, challenge_id, wod = global.cmod) {
	if !mod_is_id_component_valid(challenge_id) {
		log_error($"Mod {wod.mod_id} tried to register a challenge with invalid ID {item_id}")
		return;
	}
	if bimap_right_exists(global.registry[mod_resources.challenge], challenge) {
		var current_id = bimap_get_left(global.registry[mod_resources.challenge], challenge)
		log_error($"Mod {wod.mod_id} tried to register a challenge struct with ID {challenge_id},"
			+ $" but this struct has already been registered prior to {current_id}! Each struct registered must be unique.")	
		return;
	}
	
	static challenge_contract = {
		display_name : "",
		description : "",
		sprite : agi("spr_empty"),
		on_create : global.empty_method,
		
	}
	
	var compliance = get_struct_compliance_with_contract(challenge, challenge_contract)
	if array_length(compliance.missing) > 0 || array_length(compliance.mismatched_types) > 0 {
		log_error($"Challenge {challenge_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_compliance_error_text(challenge, challenge_contract, compliance)
			+ "\nThe challenge is not registered.")
		return;
	}
	
	var full_id = $"{wod.mod_id}:{challenge_id}"
	bimap_set(global.registry[mod_resources.challenge], full_id, challenge)
	array_push(wod.challenges)
	log_info($"Challenge {full_id} registered");
	

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
			
			ChallengeID[index] = agi("scr_Text")(challenge.display_name);
			ChallengeDesc[index] = agi("scr_Text")(challenge.description, "\n");
			ChallengeTN[index] = challenge.sprite;
			ChallengeOrder[index] = index
			
			var string_id = mod_registries_exchange(global.index_registry, global.registry, mod_resources.challenge, index)
			log_info($"challenge {string_id} has been indexed for selection screen: {index}")
				
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


