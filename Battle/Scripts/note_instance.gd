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

signal dropped

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
	if position.y > 1200:
		queue_free()

func on_bad():
	missed_sprite.visible = true
	note_sprite.visible = false
	
