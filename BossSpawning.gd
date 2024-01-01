extends Area2D
signal boss_time

func _on_body_entered(body):
	boss_time.emit()
