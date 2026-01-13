/*
This function returns a struct like so:
{
	missing (array)
	mismatched_types (array)
}
the missing array contains variable names that are present on the contract struct, but
missing on the struct parameter.

the mismatched types contains variable names that are present on both structs,
but have different types.
*/
function get_struct_compliance_with_contract(struct, contract_struct) {
	var compliance = {
		missing : [],
		mismatched_types : [],
	};
	var arr = struct_get_names(contract_struct)
	for (var i = 0; i < array_length(arr); i++) {
		var variable_name = arr[i];
		if !variable_struct_exists(struct, variable_name)
			array_push(compliance.missing, variable_name)
		else if typeof(contract_struct[$ variable_name]) != typeof(struct[$ variable_name])
			array_push(compliance.mismatched_types, variable_name)
		else {
			if (typeof(struct[$ variable_name]) == "struct") {
				var subcompliance = get_struct_compliance_with_contract(
					struct[$ variable_name], contract_struct[$ variable_name])
					
				for (var j = 0; j < array_length(subcompliance.missing); j++)
					array_push(compliance.missing, $"{variable_name}.{subcompliance.missing[i]}")
				for (var j = 0; j < array_length(subcompliance.mismatched_types); j++)
					array_push(compliance.mismatched_types, $"{variable_name}.{subcompliance.mismatched_types[i]}")
			}
		}
	}
	return compliance;
}

function generate_compliance_error_text(struct, contract_struct, compliance) {
	var text = ""
	for (var i = 0; i < array_length(compliance.missing); i++) {
		var variable_name = compliance.missing[i];
		text += $"Missing variable: {variable_name} (type: {typeof(contract_struct[$ variable_name])})\n";	
	}
	for (var i = 0; i < array_length(compliance.mismatched_types); i++) {
		var variable_name = compliance.mismatched_types[i];
		text += $"Mismatched types for variable {variable_name}: "
			+ $"got {typeof(struct[$ variable_name])}, but expected {typeof(contract_struct[$ variable_name])}\n"
	}
	string_delete(text, string_length(text), 1) // remove trailing newline
	return text;
}

function compliance_error(wod, contract, compliance, text) {
	return new result_error(new generic_error(
		text + ":\n" + generate_compliance_error_text(wod, contract, compliance)
	))
}
function initialize_missing(struct, optional_struct) {
	var arr = struct_get_names(optional_struct)
	for (var i = 0; i < array_length(arr); i++) {
		var variable_name = arr[i];
		if !variable_struct_exists(struct, variable_name)
			struct[$ variable_name] = optional_struct[$ variable_name]
		// TODO check for mismatched types
	}
}

function is_discompilant(compliance) {
	return array_length(compliance.missing) > 0 || array_length(compliance.mismatched_types) > 0;
}