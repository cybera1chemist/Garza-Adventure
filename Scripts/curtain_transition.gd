extends CanvasLayer

@onready var curtain_transition: CanvasLayer = $"."

@onready var curtain_left: Sprite2D = $Curtain_left
@onready var curtain_right: Sprite2D = $Curtain_right
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sfx_player_1: AudioStreamPlayer = $SFXPlayer1

var current_scene = null

func _ready() -> void:
	curtain_transition.visible = false
	
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	
func switch_scene(res_path):
	call_deferred("_deferred_switch_scene", res_path)
	
func _deferred_switch_scene(res_path):
	curtain_transition.visible = true
	
	animation_player.play("curtains_close")
	sfx_player_1.playing = true
	await animation_player.animation_finished
	
	res_path = "res://Scenes/" + res_path + ".tscn"
	current_scene.free()
	var scene = load(res_path)
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	animation_player.play("curtains_open")
	await animation_player.animation_finished
	curtain_transition.visible = false
