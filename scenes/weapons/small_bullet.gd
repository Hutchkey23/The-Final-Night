extends Area2D

@export var damage := 1
@export var direction := Vector2.RIGHT
@export var speed := 600.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var hit_object := false

func _physics_process(delta: float) -> void:
	if not get_viewport_rect().has_point(global_position):
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
