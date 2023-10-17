extends Node2D

func _process(delta):
	$CanvasLayer/StaminaBar.value = $Player.stamina
