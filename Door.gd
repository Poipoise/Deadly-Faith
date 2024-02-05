extends StaticBody2D
var done = false

func _on_door_detect_player_entered():
	if not done:
		$AnimationPlayer.play("DoorClosed")
		done = true
		await get_tree().create_timer(0.1).timeout
		$AudioStreamPlayer2D.play()


