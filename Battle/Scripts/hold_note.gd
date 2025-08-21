extends NoteInstance

@onready var tail_tapped: Sprite2D = $MissedSprite/Tail
@onready var body_tapped: Sprite2D = $MissedSprite/Body

@onready var tail: Sprite2D = $NoteSprite/TailSprite
@onready var body: Sprite2D = $NoteSprite/BodySprite
@onready var head: Sprite2D = $NoteSprite/HeadSprite

var is_judging_perfect: bool = false
var is_judging_good: bool = false

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
	tail.position.y = (70 - length) / 0.6
	tail_tapped.position = tail.position
	
	var scale_y = (length - 45) / 33.5
	if scale_y < 0: scale_y = 1
	body.scale = Vector2(1, scale_y)
	body_tapped.scale = body.scale
	
func _physics_process(delta: float) -> void:
	position.y += delta * flow_speed
	if can_be_judged:
		if head.position.y > TARGET_Y + 150:
			activate_next_note()
			miss.emit()
			missed_sprite.visible = true
			note_sprite.visible = false
	if tail.position.y > 1200:
		queue_free()
	# handle perfect or good
	if can_be_judged:
		if tail.position.y >= TARGET_Y-30:
			activate_next_note()
			if is_judging_perfect:
				perfect.emit()
				is_judging_perfect = false
			else:
				good.emit()
				is_judging_good = false
			disappear_after_tap()
		
func _input(event: InputEvent) -> void:
	if not can_be_judged:  return
	if event.is_action_pressed(trails[trail-1]):
		if not (is_judging_good or is_judging_perfect):
			judge()
	#elif event.is_action_released(trails[trail-1]):
		#if is_judging_good or is_judging_perfect:
			#activate_next_note()
			#miss.emit()
			#print("Release hold note, miss emit")
			#missed_sprite.visible = true
			#note_sprite.visible = false
				
func judge():
	if abs(position.y - TARGET_Y) <= PERFECT_DIFF:
		is_judging_perfect = true
	elif abs(position.y - TARGET_Y) <= GOOD_DIFF:
		is_judging_good = true
	elif abs(position.y - TARGET_Y) <= MISS_DIFF:
		activate_next_note()
		miss.emit()
		missed_sprite.visible = true
		note_sprite.visible = false
