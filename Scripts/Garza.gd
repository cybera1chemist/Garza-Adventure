extends CharacterBody2D
class_name Player

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

@export var SPEED :float = 350.0
@export_category("Camera Settings")
@export var CMR_limit_left: int
@export var CMR_limit_right: int
@export var CMR_limit_top: int
@export var CMR_limit_bottom: int
@export_category("空气墙")
@export var wall_left: int
@export var wall_right: int
@export var wall_top: int
@export var wall_bottom: int

var is_in_dialog: bool = false

func _ready() -> void:
	camera.limit_left = CMR_limit_left
	camera.limit_right = CMR_limit_right
	camera.limit_top = CMR_limit_top
	camera.limit_bottom = CMR_limit_bottom

func _physics_process(_delta: float) -> void:
	# handle player movement
	var h_direction := Input.get_axis("go_left", "go_right")
	var v_direction = Input.get_axis("go_up", "go_down")
	if not is_in_dialog:
		# Horizontal Movement
		if h_direction and h_direction > 0 and position.x+50 <= wall_right:
			velocity.x = h_direction * SPEED
			anim.flip_h = false
		elif h_direction and h_direction < 0 and position.x-50 >= wall_left:
			velocity.x = h_direction * SPEED
			anim.flip_h = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		# Vertical Movement
		if v_direction and v_direction > 0 and position.y <= wall_bottom:
			velocity.y = v_direction * SPEED
		elif v_direction and v_direction < 0 and position.y >= wall_top:
			velocity.y = v_direction * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
		
	if is_zero_approx(velocity.x) and is_zero_approx(velocity.y):
		anim.play("stand")
	else: 
		anim.play("walk")

		
