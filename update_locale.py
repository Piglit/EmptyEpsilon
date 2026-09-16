#!/usr/bin/env python3
#script to update localization files.

import glob
import subprocess
import json
import os

def get_scenario_keys(script):
	info = {}
	key = None
	for line in open(script):
		if not line.startswith("--"):
			break
		if line.startswith("---"):
			if key is not None:
				info[key] = info[key] + "\n" + line[3:].strip()
		elif ":" in line:
			key, _, value = line[2:].partition(":")
			if '[' in key and key.endswith(']'):
				additional = key[key.find('[')+1:-1]
				key = key[:key.find('[')].lower().strip()
				key = "%s[%s]" % (key, additional)
			else:
				key = key.strip().lower()
			value = value.strip()
			info[key] = value
	return info

def write_scenario_locale(output, info):
	f = open(output, "wt")
	if "name" in info:
		f.write("# Scenario name\n")
		f.write("msgid %s\n" % (json.dumps(info["name"])))
		f.write("msgstr \"\"\n")
		if "description" in info:
			f.write("# Scenario description\n")
			f.write("msgid %s\n" % (json.dumps(info["description"].replace("\r", ""))))
			f.write("msgstr \"\"\n")
		for key, value in info.items():
			if key.startswith("setting[") and key.endswith("]"):
				setting_name = key[8:-1]
				f.write("# Scenario setting\n")
				f.write("msgctxt %s\n" % (json.dumps("setting")))
				f.write("msgid %s\n" % (json.dumps(setting_name)))
				f.write("msgstr \"\"\n")
				f.write("msgctxt %s\n" % (json.dumps("setting")))
				f.write("msgid %s\n" % (json.dumps(value)))
				f.write("msgstr \"\"\n")
				for key2, value2 in info.items():
					if key2.startswith(setting_name.lower() + "[") and key2.endswith("]"):
						setting_value = key2[len(setting_name) + 1:-1]
						if "|" in setting_value:
							setting_value = setting_value[:setting_value.find("|")]
						f.write("msgctxt %s\n" % (json.dumps(setting_name)))
						f.write("msgid %s\n" % (json.dumps(setting_value)))
						f.write("msgstr \"\"\n")
						f.write("msgctxt %s\n" % (json.dumps(setting_name)))
						f.write("msgid %s\n" % (json.dumps(value2)))
						f.write("msgstr \"\"\n")
	f.close()

def handle_directory(path, skip_scenarios=False):
	os.makedirs(path + "/locale", exist_ok=True)
	for script in glob.glob(path+"/**/*.lua", recursive=True):
		output = script.replace(".lua", ".en.po").replace(path + "/", path+"/locale/")
		if "/scenario_" in script:
			if skip_scenarios:
				continue
			info = get_scenario_keys(script)
			write_scenario_locale(output, info)
		else:
			os.makedirs(os.path.dirname(output), exist_ok=True)
			f = open(output, "wt")
			f.close()
			info = {}

#		cmd = ["xgettext", "--keyword=_:1c,2", "--keyword=_:1", "--omit-header", "-j", "-d", output[:-3], "-C", "-"]
#		subprocess.run(cmd, check=True, input=b"")
		pre = open(output, "rt").read()
		cmd = ["xgettext", "--keyword=_:1c,2", "--keyword=_:1", "--add-comments=TRANSLATORS", "--omit-header", "--from-code=utf-8", "-j", "-d" , output[:-3], script]
		subprocess.run(cmd, check=True)
		post = open(output, "rt").read()
		if pre == post and "name" not in info:
			os.unlink(output)
			print("Skipped %s" % (script))
		else:
			update_other_languages(output)
			print("Done %s" % (script))

def update_other_languages(base):
    assert base.endswith(".en.po")
    for other in glob.glob(base[:-5] + "*.po"):
        if other == base:
            continue
        print("Merge %s -> %s" % (base, other))
        cmd = ["msgmerge", "-U", other, base]
        subprocess.run(cmd, check=True)

#handle_directory("scripts")
handle_directory("mod_spacelan", skip_scenarios=True)
#update_other_languages("resources/locale/main.en.po")
