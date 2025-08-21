extends Resource
class_name NoteChart

@export var bpm: float = 120.0
@export var offset: int = 0
@export var music: AudioStream
@export var flow_speed: float = 500

@export var notes: Array[Note]
