extends Node2D

@onready var ring: Sprite2D = $Ring
@onready var scatters: GPUParticles2D = $scatter_particles
@onready var heart_ring: Sprite2D = $HeartRing

@export var angular_v: float

var started: bool = false

# type
var perfect: bool
var short: bool

const HEART_PARTICLE_GOOD = preload("res://Assets/Arts/Effects/heart_particle_good.png")
const HEART_RING_GOOD = preload("res://Assets/Arts/Effects/heart_ring_good.png")
const RING_GOOD = preload("res://Assets/Arts/Effects/ring_good.png")

func _ready() -> void:
	visible = false
	scatters.emitting = false
	if short:
		scatters.one_shot = true
	else:
		scatters.one_shot = false
	heart_ring.scale = Vector2(0, 0)
		
func on_perfect():
	perfect = true
	play()
	
func on_good():
	perfect = false
	scatters.texture = HEART_PARTICLE_GOOD
	ring.texture = RING_GOOD
	heart_ring.texture = HEART_RING_GOOD
	play()

func _physics_process(delta: float) -> void:
	if not started: return
	ring.rotation += angular_v * delta

func play():
	started = true
	if short:
		scatters.one_shot = true
	else:
		scatters.one_shot = false
	visible = true
	scatters.emitting = true
	# enlarge heart ring
	enlarge_heart_ring()
	
func enlarge_heart_ring():
	# Initialize
	heart_ring.scale = Vector2.ZERO
	# Becomes larger
	var tween = create_tween()
	tween.tween_property(heart_ring, "scale", Vector2(1.2,1.2), 0.3)
	tween.tween_callback(enlarge_heart_ring).set_delay(0.3)

func stop():
	var tween = create_tween()
	tween.tween_property(ring, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
	
	tween = create_tween()
	tween.tween_property(heart_ring, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
	
	tween = create_tween()
	tween.tween_property(scatters, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
	
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	call_deferred("queue_free")
	
