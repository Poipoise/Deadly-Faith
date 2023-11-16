extends Node2D

func _process(delta):
	$CanvasLayer/StaminaBar.value = $Player.stamina



func _on_start_screen_start_game():
	pass # Replace with function body.
