extends Node2D

@onready var enemy: AnimatedSprite2D = $enemy
@onready var battle_ui: Control = $BattleUI
@onready var dialog_beginning: Control = $"Dialogs/dialog-beginning"
@onready var dialog_middle: Control = $Dialogs/dialog_middle

signal battle_start

func _ready() -> void:
	dialog_beginning.start_dialog_end.connect(on_start_dialog_end)
	battle_start.connect(battle_ui.on_battle_start)
	battle_start.connect(enemy.on_battle_start)
	battle_start.connect(dialog_middle.on_music_start)
	
func on_start_dialog_end():
	battle_start.emit()
