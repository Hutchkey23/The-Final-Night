extends CanvasLayer

@onready var ammo_label: Label = $AmmoLabel

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.connect("ammo_changed", update_ammo)
	

func update_ammo(current_mag: int, reserve: int) -> void:
	ammo_label.text = "%d/%d" % [current_mag, reserve]
