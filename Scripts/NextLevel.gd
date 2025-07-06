extends Node2D

@export var interact_area: Area2D
@export var tip_label: Label

@export_multiline var next_scene_name: String

var next_scene_path: String

func _ready() -> void:
	tip_label.visible = false
	interact_area.body_entered.connect(on_area_entered)
	interact_area.body_exited.connect(on_area_exited)
	
	next_scene_path = "res://Scenes/" + next_scene_name + ".tscn"

func on_area_entered(body: Node2D):
	if body is Player:
		tip_label.visible = true
	
func on_area_exited(body: Node2D):
	if body is Player:
		tip_label.visible = false

func _input(event: InputEvent) -> void:
	if tip_label.visible == false:
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			BlackTransition.switch_scene(next_scene_path)
