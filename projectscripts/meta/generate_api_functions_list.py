import os

base_path = os.path.abspath(os.path.join(os.getcwd(), '..', '..', 'scripts'))

list = ""

for folder_name in os.listdir(base_path):
	folder_path = os.path.join(base_path, folder_name)
	if not os.path.isdir(folder_path):
		continue

	file_path = os.path.join(folder_path, f'{folder_name}.gml')
	if not os.path.isfile(file_path):
		continue

	with open(file_path, 'r', encoding='utf-8') as f:
		for line in f:
			line = line.strip()
			if not line.startswith('function '):
				continue

			parts = line.split()
			if len(parts) < 2:
				continue

			name = parts[1].split('(')[0]
			if not name.startswith('mod_'):
				continue

			list += f"\"{name}\",\n"

print(list)