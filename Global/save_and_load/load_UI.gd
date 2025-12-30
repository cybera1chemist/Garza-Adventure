extends CanvasLayer

@onready var return_button: Button = $Panel/ReturnButton

func _ready() -> void:
	return_button.pressed.connect(exit_load_ui)
	
func exit_load_ui() -> void:
	call_deferred("queue_free")
