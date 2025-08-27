extends NoteInstance

@onready var tail_tapped: Sprite2D = $MissedSprite/Tail
@onready var body_tapped: Sprite2D = $MissedSprite/Body

@onready var tail: Sprite2D = $NoteSprite/TailSprite
@onready var body: Sprite2D = $NoteSprite/BodySprite
@onready var head: Sprite2D = $NoteSprite/HeadSprite

var is_judging: bool = false

func _ready() -> void:
	missed_sprite = $MissedSprite
	note_sprite = $NoteSprite
	note_sprite.visible = true
	missed_sprite.visible = false
	judged = false
	is_judging = false
	
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
	tail.position.y = (70 - length) / 0.6
	tail_tapped.position = tail.position
	
	var scale_y = (length - 45) / 33.5
	if scale_y < 0: scale_y = 1
	body.scale = Vector2(1, scale_y)
	body_tapped.scale = body.scale
			
func _physics_process(delta: float) -> void:
	position.y += delta * flow_speed
	if not judged and position.y + head.position.y > 1120:
		call_deferred("handle_miss")
	if position.y + tail.position.y > 1120:
		call_deferred("queue_free")
		
	if is_judging:
		pass
		
func handle_perfect():
	judged = true
	call_deferred("queue_free")
	
func handle_good():
	judged = true
	call_deferred("queue_free")
	
func handle_bad():
	judged = true
	call_deferred("queue_free")

func handle_miss():
	miss.emit()
	judged = true
	missed_sprite.visible = true
	note_sprite.visible = false
