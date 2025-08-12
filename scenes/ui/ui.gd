extends CanvasLayer

@onready var ammo_label: Label = $AmmoLabel
@onready var gun_icon: TextureRect = $GunIcon
@onready var health_bar: TextureProgressBar = $Health/HealthBar
@onready var points_label: Label = $PointsLabel

const GUN_ICON_X_SIZE := 32
const GUN_ICON_Y_SIZE := 32
var gun_icon_dict = {
	"pistol": Rect2(32, 0, GUN_ICON_X_SIZE, GUN_ICON_Y_SIZE),
	"rifle": Rect2(32, 32, GUN_ICON_X_SIZE, GUN_ICON_Y_SIZE),
	"rocket_launcher": Rect2(64, 32, GUN_ICON_X_SIZE, GUN_ICON_Y_SIZE),
	"shotgun": Rect2(96, 0, GUN_ICON_X_SIZE, GUN_ICON_Y_SIZE),
	"sniper_rifle": Rect2(0, 0, GUN_ICON_X_SIZE, GUN_ICON_Y_SIZE)
}

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.connect("ammo_changed", update_ammo)
	player.connect("health_changed", update_health)
	player.connect("weapon_changed", update_weapon)
	PointsManager.connect("points_changed", update_points)
	gun_icon.texture.region = gun_icon_dict[player.weapon_slot.current_weapon.weapon_name]
	

func update_ammo(current_mag: int, reserve: int) -> void:
	ammo_label.text = "%d/%d" % [current_mag, reserve]

func update_health(current_health, max_health) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func update_points(points) -> void:
	points_label.text = str(points)
	
func update_weapon(weapon_name) -> void:
	gun_icon.texture.region = gun_icon_dict[weapon_name]
