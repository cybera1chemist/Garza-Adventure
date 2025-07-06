extends Control

@onready var settings_button: TextureButton = $SettingsButton
@onready var tablet: TextureRect = $"./Tablet"
@onready var blur: ColorRect = $"./Blur"

@export var bgm_player : AudioStreamPlayer2D

func _ready() -> void:
	tablet.visible = false
	blur.visible = false

func _process(_delta: float) -> void:
	# Modify the volumn of bgm.
	if bgm_player:
		var volumn_linear = db_to_linear(bgm_player.volume_db)
		var target_volumn = 0.5 if get_tree().paused else 1.0
		volumn_linear = lerp(volumn_linear, target_volumn, 0.3)
		bgm_player.volume_db = linear_to_db(volumn_linear)
	
	if Input.is_action_just_pressed("show_pause_menu"):
		if tablet.visible == false:
			pause()
		else:
			unpause()

func _on_settings_button_pressed() -> void:
	pause()

func _on_resume_btn_pressed() -> void:
	unpause()
	
func _on_save_exit_btn_pressed() -> void:
	save_and_exit()
	
	
func pause() -> void:
	tablet.visible = true
	blur.visible = true
	get_tree().paused = true

func unpause() -> void:
	tablet.visible = false
	blur.visible = false
	get_tree().paused = false
	
func save_and_exit() -> void:
	get_tree().quit()
