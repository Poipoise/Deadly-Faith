extends StaticBody2D
var open = false
@export var reward : PackedScene

func _on_area_2d_body_entered(_body):
	if not open:
		open = true
		$AnimationPlayer.play("Opening")
		await get_tree().create_timer(0.2).timeout
		var world_vars = get_node("/root/World")
		world_vars.chest_opened = true
		world_vars.chest_position = position
		set_physics_process(false)
		$Area2D/CollisionShape2D.disabled = true
