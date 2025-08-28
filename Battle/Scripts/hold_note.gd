extends NoteInstance

@onready var tail_tapped: Sprite2D = $MissedSprite/Tail
@onready var body_tapped: Sprite2D = $MissedSprite/Body

@onready var tail: Sprite2D = $NoteSprite/TailSprite
@onready var body: Sprite2D = $NoteSprite/BodySprite
@onready var head: Sprite2D = $NoteSprite/HeadSprite

const ACTION_NAMES = ["lane1", "lane2", "lane3", "lane4", "lane5", "lane6", "lane7", "lane8"]
var action: String

var is_judging_perfect: bool = false
var is_judging_good: bool = false

var scale_y: float
var new_scale_y: float

func _ready() -> void:
	missed_sprite = $MissedSprite
	note_sprite = $NoteSprite
	note_sprite.visible = true
	missed_sprite.visible = false
	judged = false
	is_judging_perfect = false
	is_judging_good = false
	action = ACTION_NAMES[trail-1]
	
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
	tail.position.y = (70 - actual_length) / 0.6
	tail_tapped.position = tail.position
	
	scale_y = (actual_length - 45) / 33.5
	if scale_y < 0: scale_y = 1
	body.scale = Vector2(1, scale_y)
	body_tapped.scale = body.scale
	new_scale_y = scale_y
			
func _physics_process(delta: float) -> void:
	if (not is_judging_perfect) and (not is_judging_good):
		position.y += delta * flow_speed
		if not judged and position.y + head.position.y > 1120:
			call_deferred("handle_drop")
		if position.y + tail.position.y > 1120:
			call_deferred("queue_free")
	else:
		new_scale_y -= (scale_y+1) * delta / (length*60/bpm)
		tail.position.y += delta * flow_speed / 0.6
		tail_tapped.position = tail.position
		body.scale = Vector2(1, new_scale_y)
		body_tapped.scale = body.scale
		if head.position.y <= tail.position.y - 20:
			if not judged:
				if is_judging_perfect:
					perfect.emit()
				elif is_judging_good:
					good.emit()
			call_deferred("queue_free")

func _unhandled_input(event: InputEvent) -> void:
	if judged: return
	if (not is_judging_perfect) and (not is_judging_good): return
	if Input.is_action_just_released(action):
		handle_miss()
		
func handle_perfect():
	if judged: return
	is_judging_perfect = true

func handle_good():
	if judged: return
	is_judging_good = true

func handle_bad():
	if judged: return
	bad.emit()
	judged = true
	missed_sprite.visible = true
	note_sprite.visible = false

func handle_miss():
	if judged: return
	print("You missed a hold note! ", beat)
	judged = true
	miss.emit()
	missed_sprite.visible = true
	note_sprite.visible = false

func handle_drop():
	dropped.emit()
	judged = true
	missed_sprite.visible = true
	note_sprite.visible = false
