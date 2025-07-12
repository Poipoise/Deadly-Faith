extends StaticBody2D


func _on_golem_boss_golem_dead():
	$AnimationPlayer.play("open")
