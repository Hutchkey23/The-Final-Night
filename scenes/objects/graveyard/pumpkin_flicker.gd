extends PointLight2D

@export var flicker_speed := 0.05
@export var min_energy := 0.8
@export var max_energy := 1.2

var time_accum := 0.0

func _process(delta: float) -> void:
	time_accum += delta
	if time_accum >= flicker_speed:
		energy = randf_range(min_energy, max_energy)
		time_accum = 0.0
