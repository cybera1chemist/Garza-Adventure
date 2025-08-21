extends AnimatedSprite2D

@onready var ani: AnimatedSprite2D = $"."

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A and ani.animation != "a":
			ani.play("a")
		elif event.keycode == KEY_S and ani.animation != "s":
			ani.play("s")
		elif event.keycode == KEY_D and ani.animation != "d":
			ani.play("d")
		elif event.keycode == KEY_F and ani.animation != "f":
			ani.play("f")
		elif event.keycode == KEY_J and ani.animation != "j":
			ani.play("j")
		elif event.keycode == KEY_K and ani.animation != "k":
			ani.play("k")
		elif event.keycode == KEY_L and ani.animation != "l":
			ani.play("l")
		elif event.keycode == KEY_SEMICOLON and ani.animation != ";":
			ani.play(";")
		
func _process(_delta: float) -> void:
	var key_pressed := false
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_S) or \
		Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_F) or \
		Input.is_key_pressed(KEY_J) or Input.is_key_pressed(KEY_K) or \
		Input.is_key_pressed(KEY_L) or Input.is_key_pressed(KEY_SEMICOLON):
		key_pressed = true
	
	if not key_pressed:
		ani.play("idle")
