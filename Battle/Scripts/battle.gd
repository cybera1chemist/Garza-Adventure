extends Control

@export var battle_id: int
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

# constant
const MAX_SCORE: float = 1000000.0
const TARGET_Y: float = 970.0
const PERFECT_DIFF: float = 80.0 # unit: mili-second
const GOOD_DIFF: float = 160.0
const BAD_DIFF: float = 180.0
const combo_factor: float = 0.05

# music
var bpm: float
var music: AudioStream
var music_length: float
var flow_speed: float
var offset: int

# information during playing
var cur_combo: int = 0
var cur_score: float = 0.0
var score_per_perfect: float
var score_per_good: float
var num_perfect: int = 0
var num_good: int = 0
var num_bad: int = 0
var num_miss: int = 0
var FC: bool = true

var music_delay_time: float
var started: bool = false

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
		lane.chart = chart
		spawn_note_complete.connect(lane.on_spawn_note_complete)
	music_start.emit()

func _physics_process(_delta: float) -> void:
	combo_label.text = "Combo: " + str(cur_combo)

	if started and !audio_player.playing:
		call_deferred("switch_clear_scene")
	
	
func on_battle_start():
	music_start.emit()
	audio_player.play()
	music_delay_time = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	for note in chart.notes:
		spawn_note(note.beat, note.length, note.trail)
	spawn_note_complete.emit()
	started = true


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
		note.length = length
		note.actual_length = actual_length
	
	note.flow_speed = flow_speed	
	note.trail = trail
	note.beat = beat
	note.bpm = bpm
	
	if lanes[trail-1] == null:
		print("Error! lane object is null")
	# connect every note to battle.gd
	note.perfect.connect(on_perfect)
	note.good.connect(on_good)
	note.bad.connect(on_bad)
	note.miss.connect(on_miss)
	note.dropped.connect(on_miss)
	
	note.dropped.connect(lanes[trail-1].handle_dropped)  
	lanes[trail-1].upcoming_notes.append(note)
	
	await timer.timeout
	add_child(note)

func on_perfect():
	cur_combo += 1
	cur_score += cur_combo * combo_factor + score_per_perfect * (1-combo_factor)
	score_label.text = "%07d" % int(round(cur_score))
	num_perfect += 1

func on_good():
	num_good += 1
	cur_combo += 1
	cur_score += cur_combo * combo_factor + score_per_good * (1-combo_factor)
	score_label.text = "%07d" % int(round(cur_score))

func on_bad():
	num_bad += 1
	cur_combo = 0
	FC = false
	
func on_miss():
	num_miss += 1
	cur_combo = 0
	FC = false
	
func switch_clear_scene():
	# load clear scene
	var clear_packed_scene = preload("res://Battle/UI_Scene/battle_clear.tscn")
	var clear_scene = clear_packed_scene.instantiate()
	clear_scene.battle_id = battle_id
	clear_scene.perfect = num_perfect
	clear_scene.good = num_good
	clear_scene.bad = num_bad
	clear_scene.miss = num_miss
	clear_scene.FC = FC
	clear_scene.score = cur_score
	
	# wait for sometime
	var timer = get_tree().create_timer(3)
	await timer.timeout
	
	# free cur_scene and switch
	var root = get_tree().root
	var cur_scene = root.get_child(root.get_child_count()-1)
	root.add_child(clear_scene)
	get_tree().current_scene = clear_scene
	cur_scene.free()
