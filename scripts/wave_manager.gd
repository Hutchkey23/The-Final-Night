extends Node2D

signal wave_changed(wave_number)
signal wave_ended(wave_number)

const BASE_WAVE_AMOUNT := 5

@export var zombie_types := {
	"normal": preload("res://scenes/enemies/zombie_1.tscn")
}

# Time between spawns, in seconds
@export var spawn_delay := 1.5 

# Avoid spawning close to player
@export var min_spawn_distance := 400.0 
@export var max_spawn_distance := 550.0

var map_bounds: Rect2

var wave := 1
var wave_running = false
var zombies_remaining := 0
var zombies_to_spawn := 0
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	start_wave()
	
func start_wave() -> void:
	if wave_running:
		return
	emit_signal("wave_changed", wave)
	wave_running = true
	# More zombies in higher waves
	var base_count = BASE_WAVE_AMOUNT + wave * 2
	zombies_to_spawn = base_count
	zombies_remaining = base_count
	
	# Increase Zombie stats every X waves
	if wave % 3 == 0:
		ZombieStats.normal_zombie_health += (wave - 1)
	if wave % 5 == 0:
		ZombieStats.normal_zombie_speed = min(ZombieStats.normal_zombie_speed + 20.0, ZombieStats.MAX_ZOMBIE_SPEED)
		
	# Start spawn loop
	spawn_zombies()
	
func spawn_zombies() -> void:
	if zombies_to_spawn <= 0:
		return
		
	var spawn_point = get_random_offscreen_position()
	if spawn_point:
		var zombie_scene = choose_zombie_type()
		var zombie = zombie_scene.instantiate()
		get_tree().get_first_node_in_group("actor_container").add_child(zombie)
		zombie.global_position = spawn_point
		zombie.connect("died", on_zombie_died)
		
	zombies_to_spawn -= 1
	await get_tree().create_timer(spawn_delay).timeout
	spawn_zombies()
	
func choose_zombie_type() -> PackedScene:
	if wave < 20:
		return zombie_types["normal"]
	else:
		return
		
func on_zombie_died() -> void:
	zombies_remaining -= 1
	if zombies_remaining <= 0:
		end_wave()

func end_wave() -> void:
	if !wave_running:
		return
	wave_running = false
	emit_signal("wave_ended", wave)
	await get_tree().create_timer(1.5).timeout
	wave += 1
	start_wave()

func get_random_offscreen_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var player_pos = player.global_position
	var camera = get_viewport().get_camera_2d()
	
	# Convert screen rect to world space
	var screen_rect = Rect2(
		camera.get_screen_center_position() - viewport_rect.size / 2,
		viewport_rect.size
	)
	
	var spawn_pos: Vector2
	var max_attempts := 50  # Prevent infinite loops
	
	for i in range(max_attempts):
		# Pick random angle and distance from player
		var angle = randf() * TAU
		var distance = randf_range(min_spawn_distance, max_spawn_distance)
		spawn_pos = player_pos + Vector2.RIGHT.rotated(angle) * distance
		
		# Ensure point is not visible to camera
		if screen_rect.has_point(spawn_pos):
			continue
		
		# Ensure point is inside map bounds (assuming map is a rectangle)
		if not map_bounds.has_point(spawn_pos):
			continue
		
		# Ensure point is not inside an obstacle
		if is_point_in_obstacle(spawn_pos):
			continue
		
		return spawn_pos  # Valid spawn position found
	
	# If we can't find a position after max_attempts, just spawn at far edge
	return player_pos + Vector2.RIGHT.rotated(randf() * TAU) * max_spawn_distance

func is_point_in_obstacle(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.collide_with_areas = false
	parameters.collide_with_bodies = true
	parameters.position = pos
	var result = space_state.intersect_point(parameters)
	return result.size() > 0
	
