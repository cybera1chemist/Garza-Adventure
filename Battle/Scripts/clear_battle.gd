extends Control

@onready var background: Sprite2D = $background
@onready var painting_node: Sprite2D = $painting
# buttons
@onready var restart_button: Button = $RestartButton
@onready var proceed_button: Button = $ProceedButton


# data
@onready var level_label: Label = $level
@onready var score_label: Label = $battle_results/score
@onready var perfect_label: Label = $"battle_results/4data/perfect&bad/perfect/perfect_label"
@onready var bad_label: Label = $"battle_results/4data/perfect&bad/bad/bad_label"
@onready var good_label: Label = $"battle_results/4data/good&miss/good/good_label"
@onready var miss_label: Label = $"battle_results/4data/good&miss/miss/miss_label"


# information that need to be attained from battle:
var battle_id: int
var score: int
var perfect: int
var good: int
var bad: int
var miss: int
var FC: bool

func _ready() -> void:
	var painting_path = "res://Battle/paintings/" + str(battle_id) + ".png"
	var painting = load(painting_path)
	
	background.texture = painting
	painting_node.texture = painting
	# data
	level_label.text = judge_level()
	score_label.text = "%06d" % score
	perfect_label.text = "perfect: " + str(perfect)
	good_label.text = "good: " + str(good)
	bad_label.text = "bad: " + str(bad)
	miss_label.text = "miss: " + str(miss)
	# buttons
	restart_button.pressed.connect(_on_restart_button_pressed)
	proceed_button.pressed.connect(_on_proceed_button_pressed)
	
	# effects
	painting_node.modulate.a = 0
	painting_ease_in()
	level_label.visible = false

func judge_level() -> String:
	if score == 1000000:
		return "AP"
	elif FC:
		return "FC"
	elif score >= 950000:
		return "S"
	elif score >= 900000:
		return "A"
	elif score >= 850000:
		return "B"
	elif score >= 800000:
		return "C"
	elif score >= 750000:
		return "D"
	else:
		return "F"

func _on_restart_button_pressed() -> void:
	# curtain_transition: res_path = "res://" + res_path + ".tscn"
	print("Restart button clicked!")
	var battle_scene_path = "Battle/BattleScenes/B" + str(battle_id)
	CurtainTransition.switch_scene(battle_scene_path)
	
func _on_proceed_button_pressed() -> void:
	print("Proceed button clicked!")
	

func painting_ease_in():
	var tween = create_tween()
	tween.tween_property(painting_node, "modulate:a", 1, 1)
	
	var timer = get_tree().create_timer(1.2)
	await timer.timeout
	show_level()


func show_level():
	var tween = create_tween()
	level_label.visible = true
	level_label.scale = Vector2(2, 2)
	tween.tween_property(level_label,"scale", Vector2(1, 1), 0.5)

	
