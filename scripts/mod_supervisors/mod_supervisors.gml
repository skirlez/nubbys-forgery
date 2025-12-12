// For catspeak
function mod_register_supervisor(supervisor, supervisor_id, wod = global.cmod) {
	if !mod_is_id_component_valid(supervisor_id) {
		log_error($"Mod {wod.mod_id} tried to register a supervisor with invalid ID {item_id}")
		return;
	}
	if bimap_right_exists(global.registry[mod_resources.supervisor], supervisor) {
		var current_id = bimap_get_left(global.registry[mod_resources.supervisor], supervisor)
		log_error($"Mod {wod.mod_id} tried to register a supervisor struct with ID {supervisor_id},"
			+ $" but this struct has already been registered prior to {current_id}! Each struct registered must be unique.")	
		return;
	}
	
	static supervisor_contract = {
		display_name : "",
		description : "",
		sprites : {},
		clicked_sounds : [],
		go_sound : agi("obj_empty"),
		name_color : int64(0),
		cost : 0,
		on_create : global.empty_method,
		on_destroy : global.empty_method,
	}
	
	var compliance = get_struct_compliance_with_contract(supervisor, supervisor_contract)
	if array_length(compliance.missing) > 0 || array_length(compliance.mismatched_types) > 0 {
		log_error($"Supervisor {supervisor_id} from {wod.mod_id} has bad variables!\n" 
			+ generate_compliance_error_text(supervisor, supervisor_contract, compliance)
			+ "\nThe supervisor is not registered.")
		return;
	}
	
	static sprites_contract = {
		idle_neutral : agi("spr_empty"),
		preview : agi("spr_empty"),
	}
	var preview_sprite = supervisor.sprites.preview;
	var idle_neutral_sprite = supervisor.sprites.idle_neutral;
	
	var optional_sprites = {
		preview_clicked : preview_sprite,
		
		angry : idle_neutral_sprite,
		evil : idle_neutral_sprite,
		head_swivel : idle_neutral_sprite,
		scream : idle_neutral_sprite,
		idle_happy : idle_neutral_sprite,
		idle_sad : idle_neutral_sprite,
		idle_weird : idle_neutral_sprite,
		talk : idle_neutral_sprite,
		sad : idle_neutral_sprite,
		happy : idle_neutral_sprite,
		idle_grimace : idle_neutral_sprite
	}
	var required = get_struct_compliance_with_contract(supervisor.sprites, sprites_contract)
	var optional = get_struct_compliance_with_contract(supervisor.sprites, optional_sprites)
	var sprites_compliance = 
	{
		missing : required.missing,
		mismatched_types : array_concat(required.mismatched_types, optional.mismatched_types)
	}
	if array_length(sprites_compliance.missing) > 0 || array_length(sprites_compliance.mismatched_types) > 0 {
		log_error($"Supervisor {supervisor_id} from {wod.mod_id} has bad sprite variables!\n" 
			+ generate_compliance_error_text(supervisor.sprites, sprites_contract, sprites_compliance)
			+ "\nThe supervisor is not registered.")
		return;
	}
	
	initialize_missing(supervisor.sprites, optional_sprites)

	var full_id = $"{wod.mod_id}:{supervisor_id}"
	bimap_set(global.registry[mod_resources.supervisor], full_id, supervisor)
	array_push(wod.supervisors)
	log_info($"Supervisor {full_id} registered");
	

	// Supervisors must be indexed immediately. In principle resources need to be indexed
	// whenever the management object is actually created, and in the case of supervisors,
	// obj_GAME partially does this (storing highscores, wins, and whether or not you unlocked them)
	
	// also for some unknown reason 12 is reserved, we can't just skip to 13 otherwise the selection
	// screen gets confused, so we do this.
	var index = global.last_indices[mod_resources.supervisor] 
		+ bimap_size(global.index_registry[mod_resources.supervisor])
		+ 1
	index_supervisor(supervisor, full_id, index)
	
	return supervisor;
}


// Called from gml_Object_obj_SupervisorMGMT_Create_0
function index_supervisors_for_selection() {
	var supervisor_indices = bimap_lefts_array(global.index_registry[mod_resources.supervisor])
	for (var i = 0; i < array_length(supervisor_indices); i++) {
		var index = supervisor_indices[i]
		with (agi("obj_SupervisorMGMT")) {
			var supervisor = bimap_get_right(global.index_registry[mod_resources.supervisor], index)
			
			SuperVisorName[index] = agi("scr_Text")(supervisor.display_name);
			SuperVisorDesc[index] = agi("scr_Text")(supervisor.description, "\n");
			SVSprite[index] = supervisor.sprites.preview;
			SuperVisorCol1[index] = supervisor.name_color;
			SuperVisorCol2[index] = 255; // Unused as of now
			SVCost[index] = supervisor.cost;
			SVGoAud[index] = supervisor.go_sound;
			SVSpriteClick[index] = supervisor.sprites.preview_clicked;
			
			var string_id = mod_registries_exchange(global.index_registry, global.registry, mod_resources.supervisor, index)
			log_info($"Supervisor {string_id} has been indexed for selection screen: {index}")
				
		}
	}
}
function index_supervisor(supervisor, string_id, index) {
	var obj = allocate_object(mod_resources.supervisor, supervisor)
	// TODO. use a map for this.
	supervisor.__object = obj;
	assign_index_to_resource(mod_resources.supervisor, supervisor, index)
	
	// these are later overriden by your progress and highscore save,
	// if you have any.
	with (agi("obj_GAME")) {
		U_SV[index] = 0
		SvWins[index] = 0
		SV_HS[index] = 0;
	}
	
	log_info($"Supervisor {string_id} has been indexed: {index}")
}

// Called from gml_Object_obj_LvlMGMT_Other_4
function create_mod_supervisor_object(index_id) {
	index_id = real(index_id); // SVID is sometimes a string
	var supervisor = bimap_get_right(global.index_registry[mod_resources.supervisor], index_id);
	if supervisor == undefined
		return; // Vanilla supervisor

	var obj = supervisor.__object;
	agi("obj_LvlMGMT").SVManager = instance_create_layer(0, 0, "GAME", obj)
}

// Called from gml_Object_obj_TonyMGMT_Create_0
function register_supervisors_sprites_for_gameplay() {
	var index_id = real(agi("obj_LvlMGMT").SVID); // SVID is sometimes a string
	var supervisor = bimap_get_right(global.index_registry[mod_resources.supervisor], index_id);
	// We only need to register the sprites of the supervisor we're using, if we are using a modded one...
	if supervisor == undefined
		return;


	var sprites = supervisor.sprites;
	with (agi("obj_TonyMGMT")) {
		TonyAngrySpr[index_id] = sprites.angry
		TonyEvilSpr[index_id] = sprites.evil
		TonyHappySpr[index_id] = sprites.happy
		TonyHeadSwivelSpr[index_id] = sprites.head_swivel
		TonyIdleGrimaceSpr[index_id] = sprites.idle_grimace
		TonyIdleHappySpr[index_id] = sprites.idle_happy
		TonyIdleNeutralSpr[index_id] = sprites.idle_neutral
		TonyIdleSadSpr[index_id] = sprites.idle_sad
		TonyIdleWeirdSpr[index_id] = sprites.idle_weird
		TonySadSpr[index_id] = sprites.sad
		TonyScreamSpr[index_id] = sprites.scream
		TonyTalkSpr[index_id] = sprites.talk
	}
	var string_id = bimap_get_left(global.registry[mod_resources.supervisor], supervisor)
	log_info($"Supervisor {string_id} sprites have been indexed: {index_id}")
}

function on_supervisor_preview_choose_clicked_audio() {
	var supervisor = bimap_get_right(global.index_registry[mod_resources.supervisor], SVPreviewVal);
	if is_undefined(supervisor)
		return;
	if (array_length(supervisor.clicked_sounds) > 0)
		SVCurrentAu = supervisor.clicked_sounds[irandom_range(0, array_length(supervisor.clicked_sounds) - 1)]
	else
		SVCurrentAu = agi("snd_silence")
}

function mod_get_current_supervisor_string_id(instance) {
	
}
