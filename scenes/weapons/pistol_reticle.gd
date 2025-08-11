extends Sprite2D

func _process(delta: float) -> void:
	global_position = get_viewport().get_mouse_position()
