extends Area2D

const DESPAWN_RANGE := 450.0

@export var damage := 1
@export var direction := Vector2.RIGHT
@export var speed := 600.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var player: Player
var hit_object := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
func _physics_process(delta: float) -> void:
	# Despawn bullet if gets far enough away from player
	if global_position.distance_to(player.global_position) > DESPAWN_RANGE:
		queue_free()

	if hit_object:
		return
	
	position += direction.normalized() * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if hit_object:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	hit_object = true
	animation_player.play("bullet_hit")
