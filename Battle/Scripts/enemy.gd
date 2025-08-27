extends AnimatedSprite2D

@onready var ani: AnimatedSprite2D = $"."

@export var chart: NoteChart

var notes
var ofset
var bpm

# time variables
var begin_time: float
var music_delay_time: float
var cur_time: float

# beat variables
var note_idx: int = 0
var cur_beat: float = 0.0

func _ready() -> void:
	# Read chart
	notes = chart.notes
	ofset = chart.offset
	bpm = chart.bpm
	
	note_idx = 0
	cur_beat = 0
	ani.play("Idle")
	
func on_battle_start():
	begin_time = Time.get_ticks_msec()
	music_delay_time = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

func _physics_process(delta: float) -> void:
	cur_time = (Time.get_ticks_msec() - begin_time)/1000 - music_delay_time # unit: second
	if note_idx >= len(notes):
		change_ani("Idle")
		return
	var cur_note = notes[note_idx]
	if cur_time > (cur_note.beat + ofset) * 60 / bpm:
		if cur_time <= (cur_note.beat + ofset + cur_note.length) * 60/bpm:
			change_ani(cur_note.trail)
		else:
			note_idx += 1
	else:
		change_ani("Idle")
		
func change_ani(ani_idx):
	if ani.animation != str(ani_idx):
		ani.play(str(ani_idx))
