extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	WaveManager.connect("wave_ended", on_wave_ended)
	
func on_wave_ended(wave_number) -> void:
	animation_player.play("open")
