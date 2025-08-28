extends Control

@onready var text_panel: Panel = $TextPanel
@onready var character_name: Label = $TextPanel/MarginContainer/VBoxContainer/character_name
@onready var text_content: Label = $TextPanel/MarginContainer/VBoxContainer/text_content
@onready var typing_sfx: AudioStreamPlayer2D = $TextPanel/TypingSFX
@onready var press_space: Label = $TextPanel/MarginContainer/VBoxContainer/PressSpace


@onready var timer: Timer = $Timer

@export_category("Type")
@export var atBeginning: bool
@export var waiting_beat: float = 0.0
@export var bpm: int

@export_category("Dialog")
@export var dialog_group: DialogGroup

var dialog_index : int = 0
var dialog_len : int
var origianl_position: Vector2
var typing_tween : Tween

signal start_dialog_end

func _ready():
	dialog_len = len(dialog_group.dialog_list)
	if atBeginning:
		text_panel.visible = true
		press_space.visible = true
		display_next_dialog()
	else:
		text_panel.visible = false
		press_space.visible = false

func on_music_start():
	var waiting_time = waiting_beat * 60 / bpm
	timer.wait_time = waiting_time
	timer.start()
	await timer.timeout
	text_panel.visible = true
	display_next_dialog()

func _input(event: InputEvent) -> void:
	if not atBeginning: return
	if event.is_action_pressed("next_dialog"):
		if text_panel.visible == true:
			display_next_dialog()
		
func display_next_dialog():
	if dialog_index >= dialog_len:
		exit_dialog()
		return
		
	var dialog: Dialog = dialog_group.dialog_list[dialog_index]
	
	if atBeginning and typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_content.text = dialog.content
		dialog_index += 1
		return
	
	adjust_panel_position(dialog.character_name)
	
	character_name.text = dialog.character_name
	#text_content.text = dialog.content
	# 打字机效果：
	typing_tween = get_tree().create_tween()
	text_content.text = ""
	for letter in dialog.content:
		typing_tween.tween_callback(display_next_letter.bind(letter)).set_delay(0.06)
		typing_sfx.play()
	typing_tween.tween_callback(func(): dialog_index += 1)
	
	if not atBeginning:
		var waiting_time = 0.06 * (len(dialog.content)+10)
		var temp_timer = get_tree().create_timer(waiting_time)
		await temp_timer.timeout
		display_next_dialog()

var chinese_marks := ["，", "。", "！", "……", "？", "…", "、", "《", "》"]
func display_next_letter(letter: String):
	text_content.text += letter
	if letter not in chinese_marks:
		typing_sfx.play()
	
func exit_dialog():
	text_panel.visible = false
	if atBeginning:
		start_dialog_end.emit()
	call_deferred("queue_free")
	
func adjust_panel_position(name: String):
	if name == "嘎子：":
		position.x = 740
		position.y = 460
	else:
		position.x = 1080
		position.y = 460
