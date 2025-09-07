extends Node2D

class_name NoteInstance

#@onready var missed_sprite: Node2D = $MissedSprite
#@onready var note_sprite: Node2D = $NoteSprite
var missed_sprite: Node2D
var note_sprite: Node2D
var sfx_player: AudioStreamPlayer
var timer: Timer
var effect: Node2D

# If length == 0, then it's a short note;
# Otherwise it's a hold note.
@export var length: float = 0.0
@export var beat: float = 0.0
# trail should be 1~8
@export var trail: int = 1
@export var flow_speed = 500

const TARGET_Y: float = 970.0

var bpm: float = 158
var actual_length: float # This is only useful for hold notes

signal perfect
signal good
signal bad
signal miss
signal dropped

var judged: bool

func _ready() -> void:
	missed_sprite = $MissedSprite
	note_sprite= $NoteSprite
	sfx_player = $SFXPlayer
	timer = $Timer
	
	# Initialize effects
	effect = $HitEffect
	effect.short = true
	perfect.connect(effect.on_perfect)
	good.connect(effect.on_good)
	
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
		dropped.emit()
		call_deferred("queue_free")

func handle_perfect():
	sfx_player.play()
	judged = true
	effect.position.y = TARGET_Y-position.y
	perfect.emit()
	disapear()
	
func handle_good():
	sfx_player.play()
	judged = true
	effect.position.y = TARGET_Y-position.y
	good.emit()
	disapear()
	
func handle_bad():
	sfx_player.play()
	judged = true
	bad.emit()
	disapear()
	
func handle_miss():
	print("You missed a short note! ", beat)
	judged = true
	miss.emit()
	call_deferred("queue_free")
	
func disapear():
	missed_sprite.visible = false
	note_sprite.visible = false
	
	timer.start()
	await timer.timeout
	effect.stop()
	
	timer.start()
	await timer.timeout
	call_deferred("queue_free")
