extends CanvasLayer

@onready var black: ColorRect = $black
@onready var animation_player = $AnimationPlayer

var current_scene = null

func _ready() -> void:
	black.modulate.a = 0
	
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)

func switch_scene(res_path):
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path):
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	current_scene.free()
	var scene = load(res_path)
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	animation_player.play_backwards("fade_in")
	await animation_player.animation_finished
