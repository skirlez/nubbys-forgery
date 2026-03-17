import os
from os.path import abspath
import json
import sys

if __name__ == "__main__":
	with open("g3man/frida-user-config.jsonc", "wt") as f:
		
		
		runtime_dir = sys.argv[1]
		cache_dir = abspath(f"{runtime_dir}/../..")
		
		user_dir = sys.argv[2]

		json.dump({
			# unfortunately frida does actually check that these are real,
			# i should make it so it only checks these if you run `frida.py apply`.
			"g3man_path" : "frida.py",
			"clean_datafile_path" : "frida.py",
			"game_path": ".",
			
			"game_datafile_name" : "data.win",
			"gamemaker_cache_path" : cache_dir,
			"gamemaker_user_directory_path" : user_dir,
			"check_for_updates" : False,
			"format_version" : 1
		}, f, indent=4)
