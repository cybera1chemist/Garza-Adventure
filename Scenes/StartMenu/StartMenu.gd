extends Control

# Buttons
@onready var continue_button: Button = $ButtonGroup/ContinueButton
@onready var new_game_button: Button = $ButtonGroup/NewGameButton
@onready var collections_button: Button = $ButtonGroup/CollectionsButton
@onready var settings_button: Button = $ButtonGroup/SettingsButton
@onready var exit_button: Button = $ButtonGroup/ExitButton

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_clicked)

func _on_exit_clicked() -> void :
	get_tree().quit()
