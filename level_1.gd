extends Node2D

func _process(delta):
	$CanvasLayer/StaminaBar.value = $Player.stamina



func _on_death_screen_respawn():
	get_tree().reload_current_scene()
