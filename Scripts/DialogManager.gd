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
var npc_anim_player: AnimationPlayer
var is_playing_anim: bool = false

signal dialog_finished

func _ready():
	press_f.visible = false
	text_panel.visible = false
	origianl_position = position
	collision_shape.shape.size.x = area_x
	collision_shape.shape.size.x = area_y
	is_playing_anim = false

	if dialog_group != null:
		dialog_len = len(dialog_group.dialog_list)
	
	if NPC != null and NPC.has_node("AnimationPlayer"):
		npc_anim_player = NPC.get_node("AnimationPlayer")
	
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
	if event.is_action_pressed("next_dialog") and not is_playing_anim:
		if text_panel.visible == true:
			display_next_dialog()
		
func display_next_dialog():
	if dialog_index >= dialog_len:
		exit_dialog()
		return
		
	var dialog : Dialog = dialog_group.dialog_list[dialog_index]
	
	if dialog.type == Dialog.DialogType.SPEAK:
		if typing_tween and typing_tween.is_running():
			typing_tween.kill()
			text_content.text = dialog.content
			dialog_index += 1
			return
		adjust_panel_position(dialog.character_name)
		character_name.text = dialog.character_name
		# 打字机效果：
		typing_tween = get_tree().create_tween()
		text_content.text = ""
		for letter in dialog.content:
			typing_tween.tween_callback(display_next_letter.bind(letter)).set_delay(0.06)
			typing_sfx.play()
		typing_tween.tween_callback(func(): dialog_index += 1)

	elif dialog.type == Dialog.DialogType.ACTION:
		is_playing_anim = true
		press_f.visible = false
		text_panel.visible = false
		dialog_index += 1
		npc_anim_player.play(dialog.anim_name)
		npc_anim_player.animation_finished.connect(_on_anim_finished)
		
func _on_anim_finished(_anim_name: StringName) -> void:
	is_playing_anim = false
	if dialog_index >= dialog_len:
		exit_dialog()
		return
	press_f.visible = true
	text_panel.visible = true
	display_next_dialog()


var chinese_marks := ["，", "。", "！", "……", "？", "…", "、", "《", "》"]
func display_next_letter(letter: String):
	text_content.text += letter
	if letter not in chinese_marks:
		typing_sfx.play()
	
func exit_dialog():
	text_panel.visible = false
	position = origianl_position
	player.is_in_dialog = false
	dialog_index = 0
	SaveLoadManager.mark_dialogue_seen(dialog_group.dialog_id)
	dialog_finished.emit()
	
@warning_ignore("shadowed_variable")
func adjust_panel_position(character_name: String):
	if character_name == "嘎子：":
		global_position.x = player.position.x
		global_position.y = player.position.y - 350
	else:
		position.x = origianl_position.x
		position.y = origianl_position.y

"""
public API
"""
func set_dialog_group(new_dialog_group: DialogGroup) -> void:
	dialog_group = new_dialog_group
	dialog_index = 0
	dialog_len = len(dialog_group.dialog_list)
