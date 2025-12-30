extends Control

# Buttons
@onready var continue_button: Button = $ButtonGroup/ContinueButton
@onready var new_game_button: Button = $ButtonGroup/NewGameButton
@onready var collections_button: Button = $ButtonGroup/CollectionsButton
@onready var settings_button: Button = $ButtonGroup/SettingsButton
@onready var exit_button: Button = $ButtonGroup/ExitButton

const LOAD_UI_PATH = "res://Global/save_and_load/load_system.tscn"


func _ready() -> void:
	continue_button.pressed.connect(show_load_ui)
	new_game_button.pressed.connect(_on_new_game_button_clicked)
	exit_button.pressed.connect(_on_exit_clicked)

func show_load_ui() -> void:
	var load_scene = load(LOAD_UI_PATH).instantiate()
	get_tree().root.add_child(load_scene)

func _on_new_game_button_clicked() -> void:
	BlackTransition.switch_scene("res://Scenes/Levels/Chapter1/1-1Street.tscn")
	
func _on_exit_clicked() -> void :
	get_tree().quit()
