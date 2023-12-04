extends Node2D

func _process(delta):
	$CanvasLayer/StaminaBar.value = $Player.stamina



func _on_death_screen_respawn():
	var enemy_nodes = get_tree().get_nodes_in_group("enemy")
	for enemy in enemy_nodes:
		get_tree().reload_current_scene()
		pass
