extends Panel

@onready var filename_label: Label = $Content/LoadInfo/FilenameLabel
@onready var time_label: Label = $Content/LoadInfo/TimeLabel

@onready var load_button: Button = $Content/Buttons/LoadButton
@onready var delete_button: Button = $Content/Buttons/DeleteButton

var filename: String = "default file name"

func _ready() -> void:
	load_button.pressed.connect(load)
	delete_button.pressed.connect(delete)
	
func load() -> void:
	print("Load")
	
func delete() -> void:
	print("delete!")
	queue_free()
