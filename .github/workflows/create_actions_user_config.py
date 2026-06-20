import os
from os.path import abspath
import json
import sys

if __name__ == "__main__":
	with open("g3man/frida-user-config.jsonc", "wt") as f:
		runtime_dir = sys.argv[1]
		cache_dir = abspath(f"{runtime_dir}/../..")
		# not needed anymore lol
		# user_dir = sys.argv[2]
		json.dump({
			"gms2": {
				"cache_path": cache_dir,
			},		
			"check_for_updates": True,  
			"format_version": 1
		}, f, indent=4)
