extends Node2D

class_name Lane

@export var lane_id: int

@onready var timer: Timer = $Timer

# constants
const ACTION_NAMES = [null, "lane1", "lane2", "lane3", "lane4", "lane5", "lane6", "lane7", "lane8"]
const PERFECT_DIFF: float = 60.0
const GOOD_DIFF: float = 120.0
const MISS_DIFF: float = 160.0

var chart: NoteChart

var action: String
var upcoming_notes: Array[NoteInstance]

# Times
var begin_time: float
var music_delay_time: float
var passed_time: float
var note0_target_time: float
var note1_target_time: float

signal perfect
signal good
signal bad
signal miss

func _ready() -> void:
	action = ACTION_NAMES[lane_id]

func on_music_start():
	begin_time = Time.get_ticks_usec() # unit: micro-second

func _physics_process(delta: float) -> void:
	passed_time = Time.get_ticks_usec() - begin_time - music_delay_time
	passed_time = max(0, passed_time)

func _input(event: InputEvent) -> void:
	if upcoming_notes.size() == 0:  return
	if event.is_action_pressed(action):
		pass
		
func remove_front_note():
	if upcoming_notes.size() <= 1:
		upcoming_notes.clear()
		return
	upcoming_notes.pop_front()
