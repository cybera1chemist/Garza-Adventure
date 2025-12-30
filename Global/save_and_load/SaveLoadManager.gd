extends Node

const SAVE_DIRECTORY := "user://savegames/"
const SAVE_VERSION := "1.0"

const KEY = "SAVEKEY"

func _ready() -> void:
	print("Global save and load manager has started.")
	
var save_data = {
	"file": {
		"filename": "default save file",
		"save_time": "2025-10-1"
	},
	"playerStatus": {
		"position": Vector2(0, 0)
	}
}
	
func _save() -> void:
	# Modify save_data
	var filename: String
	save_data["file"]["filename"] = filename
	save_data["file"]["save_time"] = Time.get_datetime_string_from_system()
	
	# save the data to file
	var config = ConfigFile.new()
	for category in save_data:
		for key in save_data[category]:
			config.set_value(category, key, save_data[category][key])
	var err = config.save_encrypted_pass(SAVE_DIRECTORY+filename+".cfg", KEY)
	if err != OK:
		printerr("Err on save: ", str(err))
	else:
		print("Save file ", filename)
	
	
func _load(filename: String) -> void:
	var config = ConfigFile.new()
	var result = config.load_encrypted_pass(SAVE_DIRECTORY+filename+".cfg", KEY)
	if result != OK:
		printerr("err on load!")
	else:
		print("Loaded!")
