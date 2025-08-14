extends Node2D

@onready var ground: TileMapLayer = $TileMap/Ground
@onready var bottom_boundary: CollisionShape2D = $WorldBoundaries/BottomBoundary
@onready var top_boundary: CollisionShape2D = $WorldBoundaries/TopBoundary
@onready var left_boundary: CollisionShape2D = $WorldBoundaries/LeftBoundary
@onready var right_boundary: CollisionShape2D = $WorldBoundaries/RightBoundary

const BOTTOM_OFFSET := -10

var player: Player

func _ready() -> void:
	set_up_player_camera()

func set_up_player_camera() -> void:
	var left_bound = left_boundary.position.x
	var top_bound = top_boundary.position.y
	var right_bound = right_boundary.position.x
	var bottom_bound = bottom_boundary.position.y + BOTTOM_OFFSET


	player = get_tree().get_first_node_in_group("player")
	player.set_camera_boundaries(left_bound, right_bound, top_bound, bottom_bound)
