extends Control

@onready var text_panel: Panel = $TextPanel
@onready var character_name: Label = $TextPanel/MarginContainer/VBoxContainer/character_name
@onready var text_content: Label = $TextPanel/MarginContainer/VBoxContainer/text_content
@onready var collision_shape: CollisionShape2D = $InteractArea/CollisionShape
@onready var press_f: Label = $PressF
@onready var typing_sfx: AudioStreamPlayer2D = $TextPanel/TypingSFX


@export_category("Interact")
@export var area_x: float = 500.0
@export var area_y: float = 400.0
@export_category("Dialog")
@export var dialog_group: DialogGroup
@export var player: Player
@export var NPC: CharacterBody2D


var dialog_index : int = 0
var dialog_len : int
var origianl_position: Vector2
var typing_tween : Tween

func _ready():
	press_f.visible = false
	text_panel.visible = false
	dialog_len = len(dialog_group.dialog_list)
	origianl_position = position
	collision_shape.shape.size.x = area_x
	collision_shape.shape.size.x = area_y
	
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player and text_panel.visible == false:
		press_f.visible = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		press_f.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if press_f.visible == true:
			player.is_in_dialog = true
			press_f.visible = false
			text_panel.visible = true
			display_next_dialog()
			return
	if event.is_action_pressed("next_dialog"):
		if text_panel.visible == true:
			display_next_dialog()
		
func display_next_dialog():
	
	if dialog_index >= dialog_len:
		exit_dialog()
		return
		
	var dialog : Dialog = dialog_group.dialog_list[dialog_index]
	
	if typing_tween and typing_tween.is_running():
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

var chinese_marks := ["，", "。", "！", "……", "？", "…", "、", "《", "》"]
func display_next_letter(letter: String):
	text_content.text += letter
	if letter not in chinese_marks:
		typing_sfx.play()
	
func exit_dialog():
	text_panel.visible = false
	position = origianl_position
	player.is_in_dialog = false
	
@warning_ignore("shadowed_variable")
func adjust_panel_position(character_name: String):
	if character_name == "嘎子：":
		position.x = player.position.x
		position.y = player.position.y - 350
	else:
		position.x = NPC.position.x
		position.y = NPC.position.y - 350
