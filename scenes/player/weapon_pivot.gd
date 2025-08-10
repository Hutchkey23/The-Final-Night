extends Node2D

@export var current_weapon: Node2D

func _process(delta: float) -> void:
	rotation = wrapf(rotation, -PI, PI)
	look_at(get_global_mouse_position())
	flip_pivot()
	
func flip_pivot() -> void:
	if !current_weapon:
		return

	if rotation > PI/2 or rotation < -PI/2:
		current_weapon.scale.x = 1.0
		current_weapon.scale.y = -1.0
	else:
		current_weapon.scale.x = 1.0
		current_weapon.scale.y = 1.0
