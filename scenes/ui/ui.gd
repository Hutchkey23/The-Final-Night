extends CanvasLayer

@onready var ammo_label: Label = $AmmoLabel
@onready var health_bar: TextureProgressBar = $Health/HealthBar
@onready var points_label: Label = $PointsLabel

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.connect("ammo_changed", update_ammo)
	player.connect("health_changed", update_health)
	PointsManager.connect("points_changed", update_points)
	

func update_ammo(current_mag: int, reserve: int) -> void:
	ammo_label.text = "%d/%d" % [current_mag, reserve]

func update_health(current_health, max_health) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func update_points(points) -> void:
	points_label.text = str(points)
