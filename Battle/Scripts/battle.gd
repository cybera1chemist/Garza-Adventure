extends Control

@export var chart: NoteChart

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Lanes

@onready var lane1: Lane = $note槽/lane1
@onready var lane2: Lane = $note槽/lane2
@onready var lane3: Lane = $note槽/lane3
@onready var lane4: Lane = $note槽/lane4
@onready var lane5: Lane = $note槽/lane5
@onready var lane6: Lane = $note槽/lane6
@onready var lane7: Lane = $note槽/lane7
@onready var lane8: Lane = $note槽/lane8
var lanes: Array[Lane]

# Labels
@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var perfect_label: Label = $ForTestOnly/perfect
@onready var good_label: Label = $ForTestOnly/good
@onready var bad_label: Label = $ForTestOnly/bad
@onready var miss_label: Label = $ForTestOnly/miss


# constant
const MAX_SCORE: float = 1000000.0
const TARGET_Y: float = 970.0
const PERFECT_DIFF: float = 80.0 # unit: mili-second
const GOOD_DIFF: float = 160.0
const BAD_DIFF: float = 180.0

# music
var bpm: float
var music: AudioStream
var music_length: float
var flow_speed: float
var offset: int

# gameplay
var cur_combo: int = 0
var cur_score: float = 0.0
var score_per_perfect: float
var score_per_good: float
const combo_factor: float = 0.05
var num_perfect: int = 0
var num_good: int = 0
var num_bad: int = 0
var num_miss: int = 0

var music_delay_time: float

signal music_start
signal spawn_note_complete

func _ready() -> void:	
	lanes = [lane1, lane2, lane3, lane4, lane5, lane6, lane7, lane8]
	# Read chart
	bpm = chart.bpm
	music = chart.music
	flow_speed = chart.flow_speed
	offset = chart.offset
	
	music_length = music.get_length()
	audio_player.stream = music
	
	var l = len(chart.notes)
	score_per_perfect = (MAX_SCORE - combo_factor*l*(l+1)/2) / (l*(1-combo_factor))
	score_per_good = score_per_perfect * 0.8
	
	for lane in lanes:
		music_start.connect(lane.on_music_start)
		lane.perfect.connect(on_perfect)
		lane.good.connect(on_good)
		lane.bad.connect(on_bad)
		lane.miss.connect(on_miss)
		lane.chart = chart
		spawn_note_complete.connect(lane.on_spawn_note_complete)
	music_start.emit()

func _physics_process(_delta: float) -> void:
	combo_label.text = "Combo: " + str(cur_combo)
	perfect_label.text = "Perfect: " + str(num_perfect)
	good_label.text = "Good: " + str(num_good)
	bad_label.text = "Bad: " + str(num_bad)
	miss_label.text = "Miss: " + str(num_miss)
	
func on_battle_start():
	music_start.emit()
	audio_player.play()
	music_delay_time = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	for note in chart.notes:
		spawn_note(note.beat, note.length, note.trail)
	spawn_note_complete.emit()


func spawn_note(beat, length, trail):
	var waiting_time: float = (beat+offset)*60/bpm + music_delay_time # beat starts from 0 !!!!
	waiting_time -= (TARGET_Y) / flow_speed # +50, because note's initial position.y = -50
	if waiting_time < 0:
		waiting_time = 0
	var timer = get_tree().create_timer(waiting_time)
	
	var note: NoteInstance
	if length == 0.0: # short note
		var note_scene := preload("res://Battle/UI_Scene/note.tscn")
		note = note_scene.instantiate()
		note.length = 0.0
	else: # hold note
		var note_scene := preload("res://Battle/UI_Scene/HoldNote.tscn")
		note = note_scene.instantiate()
		var actual_length :float = length * (60/bpm) * flow_speed
		note.length = actual_length
	
	note.flow_speed = flow_speed	
	note.trail = trail
	note.beat = beat
	
	if lanes[trail-1] == null:
		print("Error! lane object is null")
	note.miss.connect(lanes[trail-1].handle_miss)
	lanes[trail-1].upcoming_notes.append(note)
	
	await timer.timeout
	add_child(note)

func on_perfect():
	cur_combo += 1
	cur_score += cur_combo * combo_factor + score_per_perfect * (1-combo_factor)
	
	combo_label.text = str(cur_combo)
	score_label.text = str(int(round(cur_score)))
	num_perfect += 1

func on_good():
	num_good += 1
	cur_combo += 1
	cur_score += cur_combo * combo_factor + score_per_good * (1-combo_factor)
	
	combo_label.text = str(cur_combo)
	score_label.text = str(int(round(cur_score)))

func on_bad():
	num_bad += 1
	cur_combo = 0
	
func on_miss():
	num_miss += 1
	cur_combo = 0
	
