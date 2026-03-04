#!/usr/bin/env python3
import os
import sys
import time
import json
import shutil
import signal
import hashlib
import zipfile
import subprocess
import urllib.request

user_config = {}

frida_version = 4



# def demand(name, can_be_empty=False):
# 	msg = f"\"{opname}\" requires {name} to be set, but it is not set. Please set it in frida-config.jsonc."
# 	if not name in options:
# 		print(msg)
# 		exit()
# 	value = options[name]
# 	if value == "" and not can_be_empty:
# 		print(msg)
# 		exit()
# 	return value

class FridaException(Exception):
	def __init__(self, message: str):
		self.message = message

### building project ### 
def hash_file(full_path: str, relative_path: str, hash_func):
	hash_func.update(relative_path.encode())
	with open(full_path, 'rb') as f:
		for chunk in iter(lambda: f.read(4096), b''):
			hash_func.update(chunk)

def hash_gamemaker_project(path: str):
	project_folder = os.path.abspath(path)
	listdir = sorted(os.listdir(project_folder))

	ignored_items = ["g3man", ".gitattributes", ".git", ".gitignore", ".frida"]
	for ignored in ignored_items:
		if ignored in listdir:
			listdir.remove(ignored)

	hash_func = hashlib.md5()
	for item in listdir:
		full_item_path = os.path.join(project_folder, item)
		if (os.path.isfile(full_item_path)):
			hash_file(full_item_path, item, hash_func)
			continue
		for root, _, files in os.walk(full_item_path, followlinks=True):
			for file_path in sorted(files):
				full_path = os.path.join(root, file_path)
				relative_path = os.path.relpath(full_path, project_folder)
				hash_file(full_path, relative_path, hash_func)

	return hash_func.hexdigest()

def cleanup():
	if os.path.isdir(".frida/igor/output"):
		print("Deleting .frida/igor/output...")
		shutil.rmtree(".frida/igor/output", ignore_errors=True)

def get_yyp_filename(path):
	for filename in os.listdir(path):
		if filename.endswith(".yyp"):
			return filename
			
	return ""

def build_gamemaker_project(mod_path: str, project_config: dict[str, str], force_build = False):
	gamemaker_project_path = f"{mod_path}/{project_config["gamemaker_project_path"]}"
	yyp_filename = get_yyp_filename(gamemaker_project_path)
	if yyp_filename == "":
		raise FridaException("Provided folder has no .yyp file")
	
	project_hash = hash_gamemaker_project(gamemaker_project_path)
	project_name = yyp_filename.removesuffix(".yyp")
	yyp_path = os.path.abspath(f"{gamemaker_project_path}/{yyp_filename}")
	
	if (not force_build):
		previous_hash = ""
		if (os.path.isfile(f".frida/igor/results/{project_name}/hash.txt")):
			with open(f".frida/igor/results/{project_name}/hash.txt", 'r') as f:
				previous_hash = f.read()
			if previous_hash != "":
				if project_hash == previous_hash:
					print(f"Previous build hash matches, skipping build for {project_name}...")
					return

	cleanup()
	print(f"---Building GameMaker project: \"{project_name}\"---")
	
	if os.name == "posix":
		IGOR_OS_SUBFOLDER="linux"
		IGOR_TARGETS=["Linux", "Package"]
		IGOR_OUTPUT_PATH="package/assets/game.unx"
		IGOR_ASSETS_FOLDER="package/assets"
		IGOR_ASSETS_FILTER=["options.ini", "icon.png"]
	elif os.name == "nt":
		IGOR_OS_SUBFOLDER="windows"
		IGOR_OUTPUT_PATH="data.win"
		IGOR_TARGETS=["Windows", "PackageZip"]
		IGOR_ASSETS_FOLDER=""
		IGOR_ASSETS_FILTER=["options.ini", "igor.output.manifest", f"{project_name}.exe"]

	runtime_path = f"{user_config["gamemaker_cache_path"]}/runtimes/runtime-{project_config["gamemaker_runtime_version"]}"
	igor_path = f"{runtime_path}/bin/igor/{IGOR_OS_SUBFOLDER}/x64/Igor"
	
	try:
		if not os.path.isdir(".frida/igor"):
			os.makedirs(".frida/igor")
		status = subprocess.run(
			[igor_path, 
			"-j=8",
			f"--user={user_config["gamemaker_user_directory_path"]}",
			f"--project={yyp_path}",
			f"--config={project_config["gamemaker_configuration"]}",
			f"--runtimePath={runtime_path}",
			"-v",
			"--tf=artifact.zip",

			IGOR_TARGETS[0],
			IGOR_TARGETS[1],
			],
			cwd = ".frida/igor")
	except Exception as e:
		print("Failed to launch igor. Do you have all your variables set correctly?\n" + str(e))
		cleanup()
		exit()

	if (status.returncode != 0):
		cleanup()
		raise FridaException("Something went wrong during building, aborting. If it's a normal issue with the project (e.g. a syntax error) it should be somewhere in the output above.")

	# I don't think there's a way to make igor not output this.
	try:
		os.remove(".frida/igor/artifact.zip")
	except:
		pass

	try:
		os.makedirs(".frida/igor/included_files", exist_ok=True)
		os.makedirs(f".frida/igor/results/{project_name}", exist_ok=True)
		os.replace(f".frida/igor/output/{project_name}/{IGOR_OUTPUT_PATH}", f".frida/igor/results/{project_name}/datafile")
		
		included_files_path = f"./igor/output/{project_name}/{IGOR_ASSETS_FOLDER}"
		new_included_files_base = ".frida/igor/included_files"
		for root, directories, files in os.walk(included_files_path):
			relative_root = os.path.relpath(root, included_files_path)
			for directory in directories:
				os.makedirs(f"{new_included_files_base}/{project_name}/{relative_root}/{directory}", exist_ok=True)
			for file in files:
				if file in IGOR_ASSETS_FILTER:
					continue
				os.replace(f"{root}/{file}", f"{new_included_files_base}/{project_name}/{relative_root}/{file}")
	except Exception as e:
		print("Failed to copy output datafile/included files from igor. Please report this bug!")
		print(e)
		exit()

	with open(f".frida/igor/results/{project_name}/hash.txt", 'w') as f:
		f.write(project_hash)
		


def symlink(target: str, output: str):
	if os.name == "nt":
		os.link(target, output)
	else:
		os.symlink(target, output)


def make_profile_json_dict(project_config: dict[str, str]):
	p = {}
	p["format_version"] = 1
	p["name"] = ""
	p["separate_modded_save"] = project_config["modded_save_name"] != ""
	p["modded_save_name"] = project_config["modded_save_name"]
	p["mod_order"] = project_config["mod_order"]
	p["description"] = ""
	p["version"] = ""
	p["credits"] = []
	p["links"] = []
	return p



### packaging mod
def package_mod(mod_path: str, project_config: dict[str, str], linkbase=False):
	profile_json = make_profile_json_dict(project_config)
	with open(f"{mod_path}/out/profile.json", "wt") as f:
		json.dump(profile_json, f)
	
	if project_config["gamemaker_project_path"] == "":
		gamemaker_project_name = ""
	else:
		gamemaker_project_name = get_yyp_filename(f"{mod_path}/{project_config["gamemaker_project_path"]}").removesuffix(".yyp")
		
	if not linkbase:
		shutil.copytree(f"{mod_path}/base", f"./out", dirs_exist_ok=True)
		#if os.path.isdir(f".frida/igor/included_files/{gamemaker_project_name}"):
		#	shutil.copytree(f".frida/igor/included_files/{gamemaker_project_name}", "./out/mod", dirs_exist_ok=True)
	else:
		for target in (f"{mod_path}/base", f"{mod_path}/igor/included_files/{gamemaker_project_name}"):
			for root, directories, files in os.walk(os.path.abspath(target), followlinks=True):
				relative_root = os.path.relpath(root, target)
				for directory in directories:
					os.makedirs(f"./out/{relative_root}/{directory}", exist_ok=True)
				for file in files:
					symlink(f"{root}/{file}",f"./out/{relative_root}/{file}")
			
	if os.path.isfile(f".frida/igor/results/{gamemaker_project_name}/datafile"):
		target_datafile_location = project_config["target_mod_datafile_location"]
		if os.path.isdir(target_datafile_location):
			target_datafile_location += "/mod_data.win"
		shutil.copy(f".frida/igor/results/{gamemaker_project_name}/datafile", target_datafile_location)
		
	for dependency in project_config["dependencies"]:
		path = dependency
		dependency_project_config = get_project_config(path)
		package_mod(path, dependency_project_config, linkbase=linkbase)
		
def package_routine(mod_path, project_config, linkbase=False):
	print(f"---Packaging mods---")
	if os.path.isdir(f"{mod_path}/out"):
		print("Deleting previous out folder...")
		shutil.rmtree(f"{mod_path}/out")
	print("Creating out folder...")
	os.mkdir(f"{mod_path}/out")
	
	package_mod(mod_path, project_config, linkbase=linkbase)

def zip_out_folder():
	if os.path.exists("./out.zip"):
		os.remove("./out.zip")
	with zipfile.ZipFile("./out.zip", "w") as f:
		for root, directories, files in os.walk("./out", followlinks=True):
			#relative_root = os.path.relpath(root, "./out")
			#for directory in directories:
			#	os.makedirs(f"./out/{relative_root}/{directory}", exist_ok=True)
			for file in files:
				f.write(f"{root}/{file}")


### applying mod ###

def apply_mod(mod_path, user_config, project_config):
	print("---Applying the mod---")
	try:
		status = subprocess.run(
			[user_config["g3man_path"], "apply",
				"--path", "out",
				"--datafile", user_config["clean_datafile_path"],
				"--out", user_config["game_path"],
				"--outname", user_config["game_datafile_name"]
			],
			cwd = ".")
	except Exception as e:
		print("Failed to launch g3man. Do you have all your variables set correctly?\n" + str(e))
		return
	if (status.returncode != 0):
		print("Something failed in g3man. Aborting.")
		exit()

### cli

def is_executable(path):
	if os.name == "nt":
		return path.endswith(".exe") or path.endswith(".bat")
	

def try_starting_game(game_path):
	executables = []
	for file in os.listdir(game_path):
		if os.access(f"{game_path}/{file}", os.X_OK):
			executables.append(f"{game_path}/{file}")
	print(executables)
	if len(executables) != 1:
		print("Couldn't determine which file is the executable. Please supply \"start_game_command\" in the user config to tell Frida what to do to launch the game.")
		return
	
	if os.name == "nt":
		pass

def strip_comments(str: str):
	build = ""
	state = 0
	for i in range(len(str) - 1):
		if state == 0:
			if str[i] == '/' and str[i + 1] == '/':
				state = 1
			elif str[i] == '/' and str[i + 1] == '*':
				state = 2
			else:
				build += str[i]
		elif state == 1:
			if str[i + 1] == '\n':
				state = 0
		elif state == 2:
			if str[i] == '*' and str[i + 1] == '/':
				state = 0
				i += 1
	return build

def fixup_paths_user_config(dict: dict[str, str]):
	for key in ["g3man_path", "game_path", "gamemaker_cache_path", "gamemaker_user_directory_path"]:
		if key in dict:
			dict[key] = dict[key].replace('\\', '/').removesuffix('/')
			
def fixup_paths_project_config(dict: dict[str, str]):
	for key in ["gamemaker_project_path", "target_mod_datafile_location"]:
		if key in dict:
			dict[key] = dict[key].replace('\\', '/').removesuffix('/')


def get_project_config(path, explore = True):
	if os.path.exists(f"{path}/frida-project-config.jsonc"):
		with open(f"{path}/frida-project-config.jsonc") as f:
			config = json.loads(strip_comments(f.read()))
			fixup_paths_project_config(config)
			return config
	if explore:
		sub = os.listdir(path)
		if len(sub) == 1 and os.path.isdir(f"{path}/{sub[0]}"):
			get_project_config(f"{path}/{sub[0]}")
		if "g3man" in sub and os.path.isdir(f"{path}/g3man"):
			get_project_config(f"{path}/g3man", explore = False)
	raise FridaException(f"Couldn't find project config in {path}")

missing_config = False
def project_config_routine(create):
	if not os.path.isfile("frida-project-config.jsonc"):
		print("No project config found in this directory.")
		global missing_config
		missing_config = True
		if create:
			print("Creating...")
			with open("frida-project-config.jsonc", "wt") as f:
				try:
					f.write(frida_template_project_config)
				except:
					print("Could not create frida-project-config.jsonc. Frida needs write access in the folder which it is used.")
					exit()
		return
	
	project_config = get_project_config(".")
	return project_config
	# TODO handle errors

def user_config_routine(create):
	global user_config
	if not os.path.isfile("frida-user-config.jsonc"):
		print("No user config found at this directory.")
		global missing_config
		missing_config = True
		if create:
			print("Creating...")
			with open("frida-user-config.jsonc", "wt") as f:
				try:
					f.write(frida_template_user_config)
				except:
					print("Could not create frida-user-config.jsonc. Frida needs write access in the folder which it is used.")
					exit()
	else:
		try:
			with open("frida-user-config.jsonc") as f:
				user_config = json.loads(strip_comments(f.read()))
				fixup_paths_project_config(user_config)
			return
		except json.JSONDecodeError as e:
			print("Couldn't read from frida-user-config.jsonc!")
			print(str(e))
			# TODO: figure out common errors
			exit()


	
	return
	
def old_setup_routine():
	if os.path.isfile("frida-config.ini"):
		print("Old setup detected. In order for this dialogue to go away, delete frida-config.ini, or read the text below.")
		print()
		print("Frida's setup has been completely changed for version 4.")
		print("Would you like your current setup to be automatically converted?")
		print()
		print("This will:")
		print("1. Split and convert \"frida-config.ini\" into \"frida-user-config.jsonc\" and \"frida-project-config.jsonc\"")
		print("2. Rename \"base/mod\" to \"base/(your mod's ID)\"")
		print()
		print("y/Y - Convert and Continue")
		print("Anything else - Exit")
		print()
		choice = input("Input your choice: ")
		if choice.lower() != "y":
			exit()
		exit()


def compare_dict_to_contract(dict, contract, issues):
	for key in contract:
		if key not in dict:
			issues.append(f"\"{key}\" is missing")
		elif type(contract[key]) != type(dict[key]):
			issues.append(f"\"{key}\" is of the wrong type: It should be {type(contract[key])}, but it's {type(dict[key])}")

frida_template_project_config = """
// This file is the project config. This file isn't personal to any user and should be shared by everyone working on the project.
// 
// You *can* use backslashes when filling out paths, but they must be escaped, i.e. you have to write "\\" instead of "\" every time.
// Save yourself the hassle and use forward slashes.

{
	// Path to the folder with this mod's GameMaker project.
	// If this mod has no GameMaker project, leaving this as blank
	// will disable GameMaker project building.
	// This path should be a relative path.
	// Relative paths, e.g. "src" means "the src folder present inside this folder", or
	// ".." meaning "the folder above this one
	"gamemaker_project_path": "",
	
	// The GameMaker runtime this project should be built for.
	// Example: "2023.4.0.113"
	"gamemaker_runtime_version": "",
	
	// The GameMaker configuration to use. If you don't know what this is, leave as "Default".
	"gamemaker_configuration": "Default",
	
	// Where Frida should place the datafile when packaging.
	// For example: to make it place the datafile in your mod's folder,
	// set this to: out/(your mod's ID)/mod_data.win
	"target_mod_datafile_location": "",
	
	// Dependencies that frida should fetch and build.
	// These can be local paths if you start the string with \"path:\"
	// or a link to a Git repository.
	// For more information, see TODO
	"dependencies": [],
	
	// This list of mod IDs determines their priority when applied into the game.
	// This list should include your mod's ID as defined in mod.json, and the IDs of any dependencies.
	// Earlier in the list means higher priority.
	"mod_order" : [],
	
	// Should the output profile set to use a separate save file folder. Leaving this as blank will use the same save folder as the vanilla game,
	// changing this will change the folder.
	"modded_save_name" : "",
	
	// This number is used for potential auto-upgrading of this file,
	// and you shouldn't change it.
	"format_version": 1
}
"""
project_config_contract = json.loads(strip_comments(frida_template_project_config))


def validate_project_config(mod_path, dict):
	issues = []
	compare_dict_to_contract(dict, project_config_contract, issues)
	if len(issues) != 0:
		return (issues, [])
	warnings = []
	gamemaker_project_path = dict["gamemaker_project_path"]
	if os.path.isabs(gamemaker_project_path):
		absolute_gamemaker_project_path = gamemaker_project_path
	else:
		absolute_gamemaker_project_path = os.path.abspath(f"{mod_path}/{gamemaker_project_path}")
	
	if gamemaker_project_path != "":
		yyp_filename = get_yyp_filename(absolute_gamemaker_project_path)
		if yyp_filename == "":
			issues.append(f"Could not find any .yyp file in \"gamemaker_project_path\" (value: \"{gamemaker_project_path}\")")
	if os.path.isabs(gamemaker_project_path):
		warnings.append(f"gamemaker_project_path is currently set to \"{gamemaker_project_path}\", which is NOT a relative path!"
					+ f"\nFrida suggests: use \"{os.path.relpath(start=".", path=gamemaker_project_path)}\" instead")

	
	
	if os.path.exists(f"{mod_path}/base"):
		unaccounted = [dir for dir in os.listdir(f"{mod_path}/base") if dir not in dict["mod_order"] and os.path.isdir(f"{mod_path}/base/{dir}")]
		if len(unaccounted) != 0:
			warnings.append(f"\"mod_order\" is missing some mods that exist in the \"base\" folder: {unaccounted}. Frida will go over these last.")
	return (issues, warnings)
	

frida_template_user_config = """
// This file is the user config. This file is personal to your computer, and shouldn't be shared.
// 
// You *can* use backslashes when filling out paths, but they must be escaped, i.e. you have to write "\\\\" instead of "\\" every time.
// Save yourself the hassle and use forward slashes.

{
	// The path to g3man's executable file.
	// https://github.com/skirlez/g3man/releases
	"g3man_path": "",
	
	// Path to the game's clean/unmodified/vanilla datafile.
	// You can't just put the path to the game's datafile here. It needs to be a separate copy,
	// because the game's datafile gets overridden after applying your mod.
	"clean_datafile_path": "",
	
	// Path to the folder of the game this project is modding
	"game_path": "",
	
	// This'll be data.win for windows, or game.unx for example on Linux.
	// Note that if you are using Proton on Steam for example, this will use the windows name.
	"game_datafile_name": "",
	
	// Using an argument, you can tell Frida to launch the game after applying your mod.
	// In case Frida cannot manage to do so automatically, you can instead have frida execute
	// this field as a command.
	"start_game_command": "",
	
	// (REQUIRED FOR BUILDING GAMEMAKER PROJECTS ONLY)
	// Linux: Likely is /home/USER/.local/share/GameMakerStudio-Beta/Cache
	// Windows: Likely is C:/ProgramData/GameMakerStudio2/Cache
	"gamemaker_cache_path": "",
	
	// (REQUIRED FOR BUILDING GAMEMAKER PROJECTS ONLY)
	// The user directory contains your license file, which is required to build GameMaker projects.
	// Linux: Likely is /home/USER/.config/GameMakerStudio2-Beta/user_somenumbers
	// Windows: Likely is C:/Users/USER/AppData/Roaming/GameMakerStudio2/user_somenumbers
	"gamemaker_user_directory_path": "",
	
	// Whether or not this script should check for updates every once in a while.
	// If set to true, it will occasionally do this after the operation you've chosen.
	"check_for_updates": true,
	
	// This number is used for potential auto-upgrading of this file,
	// and you shouldn't change it.
	"format_version": 1
}
"""
user_config_contract = json.loads(strip_comments(frida_template_user_config))

def validate_user_config(dict):
	issues = []
	compare_dict_to_contract(dict, user_config_contract, issues)
	if len(issues) != 0:
		return (issues, [])
	
	file_paths = ["g3man_path", "clean_datafile_path"]
	for path in file_paths:
		if not os.path.isfile(dict[path]):
			issues.append(f"The provided file path \"{path}\" (\"{dict[path]}\") does not exist")

	folderpaths = ["gamemaker_cache_path", "gamemaker_user_directory_path", "game_path"]
	for path in folderpaths:
		if not os.path.exists(dict[path]):
			issues.append(f"The provided folder path \"{path}\" (\"{dict[path]}\") does not exist")
	
	if os.path.exists(dict["gamemaker_cache_path"]) and not os.path.exists(f"{dict["gamemaker_cache_path"]}/runtimes"):
		issues.append(f"\"gamemaker_cache_path\" is set to \"{dict["gamemaker_cache_path"]}\", but that folder does not have a \"runtime\" subfolder.")
	
	if os.path.exists(dict["game_path"]) and not os.path.isfile(f"{dict["game_path"]}/{dict["game_datafile_name"]}"):
		valid_suffixes = [".win", ".unx", ".ios", ".droid"]
		valid_datafile_names = []
		for filename in os.listdir(dict["game_path"]):
			if any(filename.endswith(suffix) for suffix in valid_suffixes):
				valid_datafile_names.append(filename)
				
		issue = f"\"game_path\" seems to be a folder, but no file with name \"game_datafile_name\" {dict["game_datafile_name"]} was found there."

		if len(valid_datafile_names) == 0:
			issue += "\nNo valid datafile files were found in that folder as well. Are you sure this is the game folder?"
		else:
			issue += f"\nValid datafile names found in that folder: {valid_datafile_names}"
	return (issues, [])

def validate_combination(user_dict, project_dict):
	issues = []
	if (project_dict["gamemaker_runtime_version"] != ""
		and os.path.exists(f"{user_dict["gamemaker_cache_path"]}/runtimes") 
		and not os.path.exists(f"{user_dict["gamemaker_cache_path"]}/runtimes/runtime-{project_dict["gamemaker_runtime_version"]}")):
		print(f"{user_dict["gamemaker_cache_path"]}/runtimes/runtime-{project_dict["gamemaker_runtime_version"]}")
		issues.append(f"You are missing the \"{project_dict["gamemaker_runtime_version"]}\" runtime, which is required by one of the projects. Please download it from the IDE.")
	return (issues, [])
		
def validation_routine():
	user_issues, user_warnings = validate_user_config(user_config)
	project_issues, project_warnings = validate_project_config(".", project_config)
	combination_issues, combination_warnings = validate_combination(user_config, project_config)
	
	
	printed = False
	leave = False
	def print_issues_found():
		nonlocal printed
		if not printed:
			print("Configuration issue(s) found!")
			printed = True
	def set_leave():
		nonlocal leave
		if not leave:
			leave = True
	
	if len(project_issues) != 0:
		print_issues_found()
		set_leave()
		print_issues(project_issues + project_warnings, "frida-project-config.jsonc")
	elif len(project_warnings) != 0:
		print_issues_found()
		print_issues(project_warnings, "frida-project-config.jsonc")
	
	if len(user_issues) != 0:
		print_issues_found()
		set_leave()
		print_issues(user_issues + user_warnings, "frida-user-config.jsonc")
	elif len(user_warnings) != 0:
		print_issues_found()
		print_issues(user_warnings, "frida-user-config.jsonc")
		
	if len(combination_issues) != 0:
		print_issues_found()
		set_leave()
		print_issues(combination_issues + combination_warnings, "Combination of user and project configs")
	elif len(user_warnings) != 0:
		print_issues_found()
		print_issues(combination_warnings, "Combination of user and project configs")
	
	if leave:
		print("Irreconcilable issues encountered.")
		exit()
		
	

def get_options_ini_legacy():
	loptions = {}
	with open("frida-config.ini") as f:
		for line in f:
			line = line.strip()
			if line.startswith('#'):
				continue
			if not '=' in line:
				continue
			(varname, value) = line.split('=', 2)
			value = value.strip().removeprefix('"').removesuffix('"')
			loptions[varname] = value
	return loptions


timestamp_filename = "update-timestamp.txt"

def should_check_for_update():
	if not os.path.isfile(f".frida/{timestamp_filename}"):
		return True
	try:
		with open(f".frida/{timestamp_filename}", 'r') as f:
			timestamp = int(f.read())
	except:
		return True

	difference = time.time() - timestamp
	return difference > 0

def save_update_timestamp(offset):
	try:
		os.makedirs(".frida", exist_ok=True)
		with open(f".frida/{timestamp_filename}", 'w') as f:
			f.write(str(int(time.time() + offset)))
	except:
		return True


def check_update():
	print("Checking for updates...")
	print("Remember that you can disable this by setting \"check_for_updates\" to false in frida-user-config.jsonc")
	url = "https://api.github.com/repos/skirlez/frida/releases/latest"
	try:
		with urllib.request.urlopen(url) as response:
			content = json.loads(response.read().decode('utf-8'))
			tag_name = ''.join(c for c in content["tag_name"] if c.isdigit())
			tag_number = int(tag_name)
	except Exception as e:
		print("Error occured while checking for updates. You should probably check manually. See you tomorrow!")
		save_update_timestamp(86400)
		return

	if tag_number > frida_version:
		print(f"Update found! You are on version {frida_version}, and the latest version is {tag_name}.")
		print("You can update by going to https://github.com/skirlez/frida/releases/latest, downloading the script, and replacing this script with the downloaded one.")
	else:
		print("You are on the latest version.")
	
	print("See you next week!")
	save_update_timestamp(604800)
	

usage = "Usage: frida.py [ACTION] [OPTIONS]..."
def bad_usage():
	print(usage)
	print("Try 'frida.py --help' for more information.")
	exit()

def is_help(arguments):
	return "-h" in arguments or "--help" in arguments

def python_version_routine():
	if sys.version_info.major < 3 or sys.version_info.minor < 6:
		print("Frida requires Python 3.6 at least to run. Your python version: " + str(sys.version_info.major) + "." + str(sys.version_info.minor) + "." + str(sys.version_info.micro))
		exit()

def print_issues(issues, filename):
	if len(issues) == 0:
		print(f"{filename} is valid")
	else:
		print(f"{filename}:")
		for i in range(len(issues)):
			print(f"{i + 1}. {issues[i]}")
		print()

def copy_ignore_git(dir, names):
	if dir == ".":
		return [".git"]
	
	return []

def lockfile(dependency: str, value: str):
	print(f"Locking {dependency}: {value}")
	if not os.path.isfile("./frida.lock"):
		lock = dict()
	else:
		with open("./frida.lock", "r") as f:
			lock = json.load(f)
	lock[dependency] = value
	with open("./frida.lock", "w") as f:
		json.dump(lock, f)
	


def get_latest_github_release(owner, repo):
	dependency = f"github:{owner}/{repo}"
	if os.path.isfile("./frida.lock"):
		with open("./frida.lock", "r") as f:
			lock = json.load(f)
		if dependency in lock:
			return lock[dependency]
	url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
	try:
		with urllib.request.urlopen(url) as response:
			content = json.loads(response.read().decode('utf-8'))
			tag_name = content["tag_name"]
	except Exception as e:
		raise FridaException(f"Failed to fetch latest release of github:{owner}/{repo}")
	lockfile(dependency, tag_name)
	return tag_name
	
def get_latest_github_commit(owner, repo, branch):
	dependency = f"github:{owner}/{repo}/{branch}"
	if os.path.isfile("./frida.lock"):
		with open("./frida.lock", "r") as f:
			lock = json.load(f)
		if dependency in lock:
			return lock[dependency]
	url = f"https://api.github.com/repos/{owner}/{repo}/branches/{branch}"
	try:
		with urllib.request.urlopen(url) as response:
			content = json.loads(response.read().decode('utf-8'))
			commit = content["commit"]
			sha = commit["sha"]
	except Exception as e:
		raise FridaException(f"Failed to fetch latest release of github:{owner}/{repo}")
	lockfile(dependency, sha)
	return sha

def fetch_dependencies(mod_path: str, project_config: dict[str, str]):
	for dependency in project_config["dependencies"]:
		parts = dependency.split(':')
		if len(parts) == 1:
			raise FridaException(f"Dependency {dependency} does not have a prefix. You need to specify a prefix, like \"path:\", or \"github:\".")
		if len(parts) > 2:
			raise FridaException(f"Dependency {dependency} is of an invalid format; it should only have one colon ':' character.")
		prefix = parts[0]
		if prefix == "path":
			path = parts[1]
			dependency_project_config = get_project_config(path)
			fetch_dependencies(path, dependency_project_config)
		if prefix == "github":
			subparts = parts[1].split('/')
			user = subparts[0]
			repo = subparts[1]
			
			if len(subparts) == 2:
				tag_name = get_latest_github_release(user, repo)
				zip_url = f"https://api.github.com/repos/{user}/{repo}/zipball/{tag_name}"
				target_path = f".frida/deps/github-{user}-{repo}"
			if len(subparts) == 3:
				branch = subparts[2]
				commit_hash = get_latest_github_commit(user, repo, branch)
				zip_url = f"https://github.com/{user}/{repo}/archive/{commit_hash}.zip"
				target_path = f".frida/deps/github-{user}-{repo}-{branch}"
			
			os.makedirs(target_path, exist_ok=True)
			urllib.request.urlretrieve(zip_url, ".frida/tmp.zip")
			with zipfile.ZipFile(".frida/tmp.zip", "r") as f:
				f.extractall(target_path)
			os.remove(".frida/tmp.zip")
			dependency_project_config = get_project_config(target_path)
			fetch_dependencies(target_path, dependency_project_config)

def build_routine(mod_path: str, project_config: dict[str, str], force_build = False):
	project_path = project_config["gamemaker_project_path"]
	if project_path != "":
		build_gamemaker_project(mod_path, project_config,
								force_build=force_build)
	
	
	for dependency in project_config["dependencies"]:
		parts = dependency.split(':')
		if len(parts) == 1:
			raise FridaException(f"Dependency {dependency} does not have a prefix. You need to specify a prefix, like \"path:\", or \"github:\".")
		if len(parts) > 2:
			raise FridaException(f"Dependency {dependency} is of an invalid format; it should only have one colon ':' character.")
		prefix = parts[0]
		if prefix == "path":
			path = parts[1]
			#os.makedirs(".frida/deps/test", exist_ok=True)
			#shutil.copytree(path, f".frida/deps/test", dirs_exist_ok=True, 
			#	ignore=lambda dir, names: copy_ignore_git(os.path.relpath(dir, path), names))
			dependency_project_config = get_project_config(path)
			build_routine(path, dependency_project_config, force_build=force_build)
		if prefix == "github":
			subparts = parts[1].split('/')
			user = subparts[0]
			repo = subparts[1]
			if len(subparts) == 2:
				path = f".frida/deps/github-{user}-{repo}"
			if len(subparts) == 3:
				branch = subparts[2]
				path = f".frida/deps/github-{user}-{repo}-{branch}"
				
			dependency_project_config = get_project_config(path)
			build_routine(path, dependency_project_config, force_build=force_build)
		

if __name__ == "__main__":
	python_version_routine()
	# Let me Ctrl+C in peace
	signal.signal(signal.SIGINT, lambda a, b: exit())
	
	old_setup_routine()
	
	create = "--createconfig" in sys.argv
	
	project_config = project_config_routine(create)
	user_config_routine(create)
	
	if missing_config:
		if not create:
			print("Configuration files are missing in this directory. You can run \"frida.py --createconfig\" to create them.")
			exit()
		print("Configuration file(s) have been created.")
		print("You can run \"frida.py validate\" in order to validate your config(s), after filling them.")
		exit()
	
	if (len(sys.argv) < 2):
		bad_usage()
	argument = sys.argv[1]
	if argument == '--help' or argument == 'h':
		print(usage)
		print("Perform ACTION in accordance to frida-project-config.jsonc and frida-user-config.jsonc in the same directory.")
		print()
		print("Actions list:")
		print("    build")
		print("    package [--zip-all] [--zip-single]")
		print("    apply [--linkbase]")
		print("    validate")
		print("    check_updates")
		print()
		print("You can use '--help' on each of the actions to learn more about them and their options.")
		exit()

	subarguments = sys.argv[2:]
	opname = argument
	if argument == "fetch":
		if is_help(subarguments):
			print("frida.py fetch - Fetches the mod's dependencies.")
			exit()
		validation_routine()
		fetch_dependencies(".", project_config)
	if argument == "build":
		if is_help(subarguments):
			print("frida.py build - Builds the mod's and dependencies' GameMaker projects.")
			print()
			print("This action will attempt to build the projects regardless of the previous builds' hashes.")
			print()
			print("The output artifacts will be in .frida/igor.")
			print()
			exit()
		validation_routine()
		build_routine(".", project_config, force_build=True)
		
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "package":
		if is_help(subarguments):
			print("frida.py package - Packages this mod.")
			print()
			print("This action will build the GameMaker project(s) if necessary, and package this")
			print("mod and its dependencies as a profile folder \"out\", for distribution or application.")
			print()
			print("Arguments:")
			
			print("  -za, --zip-all        After creating the \"out\" folder, compress it into a ZIP (as \"profile.zip\")")
			print("  -zs, --zip-single     After creating the \"out\" folder, compress the first mod in the mod order (as \"mod.zip\")")
			
			exit()
		validation_routine()
		build_routine(".", project_config)
		package_routine(".", project_config=project_config, linkbase=False)
		zip_all = "-za" in subarguments or "--zip-all" in subarguments 
		if zip_all:
			zip_out_folder()
		zip_single = "-zs" in subarguments or "--zip-s" in subarguments 
		if zip_single:
			zip_out_folder()
		print(f"Done!")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "apply":
		if is_help(subarguments):
			print("frida.py apply [ARGUMENTS] - Applies this mod.")
			print()
			print("This action will build the GameMaker project(s) if necessary, package the mod and its dependencies,")
			print("And then call g3man to apply it on a GameMaker game.")
			print()
			print("Arguments:")
			
			print("  -l, --linkbase     When packaging, link files in \"out\" to \"base\" instead of copying")
			indent = "                       "
			print(f"{indent}This is useful if your mod has included files it reads from at runtime,")
			print(f"{indent}as this argument effectively makes it so any changes to files in \"base\"")
			print(f"{indent}are visible to the modded game immediately.")
			print(f"{indent}Note: This argument uses hard links on Windows")
			print(f"{indent}and symlinks everywhere else.")
			print()
			print("  -s, --startgame    After applying, attempt to launch the game")
			
			print(f"{indent}Frida will try to open any executable found in the game's folder.")
			print(f"{indent}If there's more than one, or the launch fails for whatever reason,")
			print(f"{indent}you must set \"start_game_command\" in frida-user-config.jsonc")
			print(f"{indent}which Frida will execute in the game's folder.")
			exit()
		linkbase = "-l" in subarguments or "--linkbase" in subarguments 
		validation_routine()
		build_routine(".", project_config)
		package_routine(".", project_config=project_config, linkbase=linkbase)
		apply_mod(".", user_config, project_config)
		
		startgame = "-s" in subarguments or "--startgame" in subarguments 
		if startgame:
			try_starting_game(user_config["game_path"])
		print("Done! Your mod has been applied.")
		if (should_check_for_update()):
			check_update()
		exit()
	if argument == "validate":
		if is_help(subarguments):
			print("frida.py validate - Validates config files in the current directory.")
			print()
			print("This action will go over some of the fields in frida-user-config.jsonc and frida-project-config.jsonc,")
			print("and will let you know if there's anything wrong with them.")
			exit()
		project_issues, project_warnings = validate_project_config(".", project_config)
		user_issues, user_warnings = validate_user_config(user_config)
		combination_issues, combination_warnings = validate_combination(user_config, project_config)
		print_issues(project_issues + project_warnings, "frida-project-config.jsonc")
		print_issues(user_issues + user_warnings, "frida-user-config.jsonc")
		print_issues(combination_issues + combination_warnings, "Combination of user and project configs")
		exit()
	if argument == "check_updates":
		if is_help(subarguments):
			print("frida.py check_updates - Checks for updates to Frida.")
			print()
			print("This action will check https://github.com/skirlez/frida/releases,")
			print("And print a message if there's a newer version.")
			exit()
		check_update()
		exit()


	bad_usage()
