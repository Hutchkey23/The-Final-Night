extends Node

@export var zombie_types := {
	"normal": preload("res://scenes/enemies/zombie_1.tscn")
}

# Time between spawns, in seconds
@export var spawn_delay := 1.5 

# Avoid spawning close to player
@export var min_spawn_distance := 400.0 
@export var max_spawn_distance := 750.0


var wave := 1
var zombies_remaining := 0
var zombies_to_spawn := 0
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	start_wave()
	
func start_wave() -> void:
	# More zombies in higher waves
	var base_count = 5 + wave * 2
	zombies_to_spawn = base_count
	zombies_remaining = base_count
	
	# Increase Zombie stats every 5 waves
	#ZombieStats.health = 100 + (wave - 1) * 10
	#if wave % 5 == 0:
		#ZombieStats.speed += 20
		
	# Start spawn loop
	spawn_zombies()
	
func spawn_zombies() -> void:
	if zombies_to_spawn <= 0:
		return
		
	var spawn_point = get_random_offscreen_position()
	if spawn_point:
		var zombie_scene = choose_zombie_type()
		var zombie = zombie_scene.instantiate()
		get_parent().add_child(zombie)
		zombie.global_position = spawn_point
		zombie.connect("died", on_zombie_died)
		
	zombies_to_spawn -= 1
	await get_tree().create_timer(spawn_delay).timeout
	spawn_zombies()
	
func choose_zombie_type() -> Node2D:
	if wave < 5:
		return zombie_types["normal"]
	else:
		return
		
func on_zombie_died() -> void:
	zombies_remaining -= 1
	if zombies_remaining <= 0:
		print("WAVE OVER")
	
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
	
	while true:
		# Pick random angle and distance from player
		var angle = randf() * TAU
		var distance = randf_range(min_spawn_distance, max_spawn_distance)
		spawn_pos + Vector2.RIGHT.rotated(angle) * distance
		
		# Only accept position if it's NOT in the camera view
		if not screen_rect.has_point(spawn_pos):
			break
			
	return spawn_pos
