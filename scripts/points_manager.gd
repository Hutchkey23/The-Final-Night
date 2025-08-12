extends Node

signal points_changed(points)

var points_per_hit: int = 10
var points_per_kill: int = 100
var point_multiplier: int = 1

var points: int = 0
var total_points_this_run: int = 0

func add_points(amount: int) -> void:
	points += amount * point_multiplier
	emit_signal("points_changed", points)

func reset_points() -> void:
	points = 0
	total_points_this_run = 0
	emit_signal("points_changed", points)
