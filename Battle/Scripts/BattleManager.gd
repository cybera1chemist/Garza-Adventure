extends Node2D

@onready var enemy: AnimatedSprite2D = $enemy
@onready var battle_ui: Control = $BattleUI

signal battle_start

func _ready() -> void:
	battle_start.connect(battle_ui.on_battle_start)
	battle_start.connect(enemy.on_battle_start)
	
	battle_start.emit()
