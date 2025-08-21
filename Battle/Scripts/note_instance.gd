extends Node2D

class_name NoteInstance

@onready var missed_sprite: Node2D = $MissedSprite
@onready var note_sprite: Node2D = $NoteSprite

# If length == 0, then it's a short note;
# Otherwise it's a hold note.
@export var length: float = 0.0
@export var beat: float = 0.0
# trail should be 1~8
@export var trail: int = 1
@export var flow_speed = 500

const TARGET_Y: float = 970.0
const PERFECT_DIFF: float = 60.0
const GOOD_DIFF: float = 120.0
const MISS_DIFF: float = 160.0

const trails = ["trail_1", "trail_2", "trail_3", "trail_4",
				"trail_5", "trail_6", "trail_7", "trail_8"]

var can_be_judged: bool = true
var next_note: NoteInstance = null

signal perfect
signal good
signal miss

func _ready() -> void:
	note_sprite.visible = true
	missed_sprite.visible = false
	
	# check parameters
	if trail < 1 or trail > 8:
		print("trail should be from 1 to 8!")
		return
		
	# Settle the position
	position.x = 225 + (trail-1) * 210
	if trail <= 4:
		position.x -= 10
	else:
		position.x += 10
	position.y = -50
	
func _physics_process(delta: float) -> void:
	position.y += delta * flow_speed
	if can_be_judged: 
		if position.y > TARGET_Y + 150: # 没接住
			activate_next_note()
			miss.emit()
			can_be_judged = false
	if position.y > 1200:
		queue_free()

func _input(event: InputEvent) -> void:
	if not can_be_judged:  return
	if event.is_action_pressed(trails[trail-1]):
		judge()
				
func judge():
	if not can_be_judged:  return
	if abs(position.y - TARGET_Y) <= PERFECT_DIFF:
		activate_next_note()
		perfect.emit()
		disappear_after_tap()
	elif abs(position.y - TARGET_Y) <= GOOD_DIFF:
		activate_next_note()
		good.emit()
		disappear_after_tap()
	elif abs(position.y - TARGET_Y) <= MISS_DIFF:
		activate_next_note()
		miss.emit()
		var timer = get_tree().create_timer(1)
		await timer.timeout
		queue_free()

func disappear_after_tap():
	# 暂时这样！还要加特效！
	queue_free()
	
func activate_next_note():
	# deactivate itself
	can_be_judged = false
	
	if next_note == null: return
	var next_beat = next_note.beat
	var cur_note = next_note
	# handle multiple simultaneous notes
	while cur_note != null:
		cur_note.can_be_judged = true
		if cur_note.beat != next_beat:
			break
		cur_note = cur_note.next_note
