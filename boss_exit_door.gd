extends StaticBody2D


func _on_necromancer_died():
	$AnimationPlayer.play("DoorOpen")
