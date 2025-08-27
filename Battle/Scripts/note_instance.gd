extends Node2D

class_name NoteInstance

#@onready var missed_sprite: Node2D = $MissedSprite
#@onready var note_sprite: Node2D = $NoteSprite
var missed_sprite: Node2D
var note_sprite: Node2D

# If length == 0, then it's a short note;
# Otherwise it's a hold note.
@export var length: float = 0.0
@export var beat: float = 0.0
# trail should be 1~8
@export var trail: int = 1
@export var flow_speed = 500

const TARGET_Y: float = 970.0

signal miss

var judged: bool

func _ready() -> void:
	missed_sprite = $MissedSprite
	note_sprite= $NoteSprite
	
	note_sprite.visible = true
	missed_sprite.visible = false
	
	judged = false
	
	# check parameters
	if trail < 1 or trail > 8:
		print("trail should be from 1 to 8!")
		return
		
	# Settle the position
	position.x = 225 + (trail-1) * 210
	if trail <= 4:
		position.x -= 25
	else:
		position.x += 25
	position.y = -50
	
func _physics_process(delta: float) -> void:
	if judged: return
	position.y += delta * flow_speed
	if position.y > 1120:
		miss.emit()
		judged = true
		call_deferred("queue_free")

func handle_perfect():
	judged = true
	call_deferred("queue_free")
	
func handle_good():
	judged = true
	call_deferred("queue_free")
	
func handle_bad():
	judged = true
	call_deferred("queue_free")
