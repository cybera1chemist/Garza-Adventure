extends Control

@export var chart: NoteChart

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel

@onready var perfect_label: Label = $ForTestOnly/perfect
@onready var good_label: Label = $ForTestOnly/good
@onready var miss_label: Label = $ForTestOnly/miss


# constant
const MAX_SCORE: float = 1000000.0
const target_y: float = 970.0

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
var num_miss: int = 0

# Linked Array
var head_notes: Array[NoteInstance] = [null, null, null, null, null, null, null, null]
var tail_notes: Array[NoteInstance] = [null, null, null, null, null, null, null, null]

func _ready() -> void:
	# Read chart
	bpm = chart.bpm
	music = chart.music
	flow_speed = chart.flow_speed
	offset = chart.offset
	
	music_length = music.get_length()
	audio_player.stream = music
	
	var l = len(chart.notes)
	score_per_perfect = (MAX_SCORE - combo_factor*l*(l+1)/2) / (l*(1-combo_factor))
	score_per_good = score_per_perfect * 0.9
	
	music_start()

func _process(delta: float) -> void:
	combo_label.text = "Combo: " + str(cur_combo)
	perfect_label.text = "Perfect: " + str(num_perfect)
	good_label.text = "Good: " + str(num_good)
	miss_label.text = "Miss: " + str(num_miss)
	
func music_start():
	audio_player.play()
	for note in chart.notes:
		spawn_note(note.beat, note.length, note.trail)


func spawn_note(beat, length, trail):
	var waiting_time: float = (beat+offset)*60/bpm # beat starts from 0 !!!!
	waiting_time -= (target_y+50) / flow_speed
	if waiting_time < 0:
		waiting_time = 0
	var timer = get_tree().create_timer(waiting_time)
	
	var note
	if length == 0.0: # short note
		var note_scene := load("res://Battle/UI_Scene/note.tscn")
		note = note_scene.instantiate()
		note.length = 0.0
	else: # hold note
		var note_scene := load("res://Battle/UI_Scene/HoldNote.tscn")
		note = note_scene.instantiate()
		var actual_length :float = length * (60/bpm) * flow_speed
		note.length = actual_length
	
	note.flow_speed = flow_speed	
	note.trail = trail
	note.perfect.connect(on_perfect)
	note.good.connect(on_good)
	note.miss.connect(on_miss)
	
	if head_notes[trail-1] == null:
		head_notes[trail-1] = note
		tail_notes[trail-1] = note
		note.can_be_judged = true
	else:
		tail_notes[trail-1].next_note = note
		tail_notes[trail-1] = note
		note.can_be_judged = false
	
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

func on_miss():
	num_miss += 1
	cur_combo = 0
	
