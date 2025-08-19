extends Node2D

signal transition_to_exterior(player)

@onready var spawn_point: Node2D = $SpawnPoint


func _on_transition_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("transition_to_exterior", body)
