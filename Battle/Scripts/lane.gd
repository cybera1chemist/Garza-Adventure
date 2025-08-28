extends Node2D

class_name Lane

@export var lane_id: int

@onready var audio_player: AudioStreamPlayer = $"../../AudioStreamPlayer"

# constants
const ACTION_NAMES = ["lane1", "lane2", "lane3", "lane4", "lane5", "lane6", "lane7", "lane8"]
const PERFECT_DIFF: float = 100.0 # unit: millisecond
const GOOD_DIFF: float = 200.0
const BAD_DIFF: float = 250.0

var chart: NoteChart

var action: String
var upcoming_notes: Array[NoteInstance]

# Times
var begin_time: float
var music_delay_time: float
var passed_time: float
var first_target_time: float
var time: float

var cur_note: int
var started: bool
var ended: bool

signal perfect
signal good
signal bad
signal miss

func _ready() -> void:
	cur_note = 0
	started = false
	ended = false
	action = ACTION_NAMES[lane_id-1]

func on_music_start():
	begin_time = Time.get_ticks_usec() # unit: micro-second
	music_delay_time = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

func on_spawn_note_complete():
	first_target_time = note_target_time(upcoming_notes[0])
	started = true

# Engine.iterations_per_second
func _physics_process(_delta: float) -> void:
	passed_time = (Time.get_ticks_usec() - begin_time)/1000 # unit: millisecond
	passed_time -= music_delay_time * 1000
	passed_time = max(0, passed_time)
	time = (audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()) * 1000

var old_note: NoteInstance
func _input(event: InputEvent) -> void:
	if not started or ended: return
	if event.is_action_pressed(action):
		if upcoming_notes.size() > 0:
			old_note = upcoming_notes[0]
		if upcoming_notes.size() >= 1:
			first_target_time = note_target_time(old_note)
		if abs(first_target_time - time) <= PERFECT_DIFF:
			perfect.emit()
			print("Perfect! Beat: ", old_note.beat)
			remove_front_note()
			old_note.handle_perfect()
		elif abs(first_target_time - time) <= GOOD_DIFF:
			print("Good! Beat: ", old_note.beat)
			good.emit()
			remove_front_note()
			old_note.handle_good()
		elif abs(first_target_time - time) <= BAD_DIFF:
			print("Bad! Beat: ", old_note.beat)
			remove_front_note()
			bad.emit()
			old_note.handle_bad()

func remove_front_note():
	upcoming_notes.pop_front()
	if len(upcoming_notes) > 0:
		first_target_time = note_target_time(upcoming_notes[0])
	else: # array emptied
		first_target_time = 99999999999999999
		ended = true

func note_target_time(note: NoteInstance):
	# unit: millisecond
	return 1/chart.bpm * (note.beat+chart.offset) * 60 * 1000

func handle_miss():
	if ended: return
	print("Miss!")
	miss.emit()
	remove_front_note()
	
