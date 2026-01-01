extends Node

const SAVE_DIRECTORY := "user://savegames/"
const SAVE_VERSION := "1.0"

const KEY = "SAVEKEY"

var save_data = {
	"file": {
		"filename": "default save file",
		"save_time": "2025-10-1"
	},
	"playerStatus": {
		"position": Vector2(0, 0)
	},
	"story": {
		"current_chapter": 0,
		"seen_dialogs": []
	}
}

func _ready() -> void:
	print("Global save and load manager has started.")
	
func _save() -> void:
	# Modify save_data.
	# Only need to modify filename and save_time. 
	# Other data should be modified elsewhere in the game.
	var filename: String
	save_data["file"]["filename"] = filename
	save_data["file"]["save_time"] = Time.get_datetime_string_from_system()
	
	# Save the data to file.
	var config = ConfigFile.new()
	for category in save_data:
		for key in save_data[category]:
			config.set_value(category, key, save_data[category][key])
	var err = config.save_encrypted_pass(SAVE_DIRECTORY+filename+".cfg", KEY)
	if err != OK:
		printerr("Err on save: ", str(err))
	else:
		print("Save file ", filename, " saved successfully.")
	
	
func _load(filename: String) -> void:
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass(SAVE_DIRECTORY+filename+".cfg", KEY)
	if result != OK:
		printerr("Err on load: ", str(result))
	else:
		for category in save_data:
			for key in save_data[category]:
				save_data[category][key] = config.get_value(category, key, save_data[category][key])
		print("Loaded save file ", filename, " successfully.")

"""
API
"""

func has_seen_dialogue(id: int) -> bool:
	return id in save_data["story"]["seen_dialogs"]

func mark_dialogue_seen(id: int) -> void:
	if not has_seen_dialogue(id):
		save_data["story"]["seen_dialogs"].append(id)
