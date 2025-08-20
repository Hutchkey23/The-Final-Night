extends Node2D

@onready var ground: TileMapLayer = $TileMap/Ground
@onready var world_boundaries: StaticBody2D = $WorldBoundaries
@onready var bottom_boundary: CollisionShape2D = $WorldBoundaries/BottomBoundary
@onready var top_boundary: CollisionShape2D = $WorldBoundaries/TopBoundary
@onready var left_boundary: CollisionShape2D = $WorldBoundaries/LeftBoundary
@onready var right_boundary: CollisionShape2D = $WorldBoundaries/RightBoundary
@onready var exit_mausoleum_spawn_point: Node2D = $ExitMausoleumSpawnPoint
@onready var mausoleum: StaticBody2D = $YSort/ActorsContainer/Objects/Mausoleum
@onready var mausoleum_interior: Node2D = $YSort/MausoleumInterior

const BOTTOM_OFFSET := -10

var boundaries_enabled := true
var player: Player

func _ready() -> void:
	WaveManager.in_mausoleum = false
	mausoleum.connect("transition_to_interior", on_transition_to_interior)
	mausoleum_interior.connect("transition_to_exterior", on_transition_to_exterior)
	set_up_player_camera("exterior")

func set_up_player_camera(location: String) -> void:
	var left_bound
	var top_bound
	var right_bound
	var bottom_bound
	if location == "exterior":
		left_bound = left_boundary.position.x
		top_bound = top_boundary.position.y
		right_bound = right_boundary.position.x
		bottom_bound = bottom_boundary.position.y + BOTTOM_OFFSET
	elif location == "interior":
		left_bound = -100000
		top_bound = -100000
		right_bound = 100000
		bottom_bound = 100000

	player = get_tree().get_first_node_in_group("player")
	player.set_camera_boundaries(left_bound, right_bound, top_bound, bottom_bound)

func on_transition_to_interior(player: Player):
	WaveManager.in_mausoleum = true
	set_up_player_camera("interior")
	toggle_boundaries()
	player.toggle_camera_smoothing()
	player.global_position = mausoleum_interior.spawn_point.global_position
	player.offset_camera("down")
	await get_tree().process_frame
	player.smooth_camera_to_player()
	player.toggle_camera_smoothing()

func on_transition_to_exterior(player: Player):
	set_up_player_camera("exterior")
	player.toggle_camera_smoothing()
	player.global_position = exit_mausoleum_spawn_point.global_position
	player.offset_camera("up")
	await get_tree().process_frame
	player.smooth_camera_to_player()
	player.toggle_camera_smoothing()
	toggle_boundaries()
	player.can_move = false
	await get_tree().create_timer(0.5).timeout
	mausoleum.close_door()
	WaveManager.in_mausoleum = false
	WaveManager.start_wave()
	player.can_move = true


func toggle_boundaries():
	if boundaries_enabled:
		world_boundaries.process_mode = Node.PROCESS_MODE_DISABLED
		world_boundaries.set_physics_process(false)
	else:
		world_boundaries.process_mode = Node.PROCESS_MODE_INHERIT
		world_boundaries.set_physics_process(true)
