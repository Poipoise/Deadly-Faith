extends Node2D
@export var light_orb: PackedScene
var player
func _on_world_orb_spawner():
	player = $"../Player"
	for i in range(3):
		var orb = light_orb.instantiate()
		get_parent().add_child(orb)
		orb.global_position = global_position
		orb.bounce = false
		orb.speed = 360
		var base_dir = (player.global_position - orb.global_position).normalized()
		orb.velocity = base_dir * orb.speed
		await get_tree().create_timer(1.5).timeout
		
