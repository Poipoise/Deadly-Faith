extends Area2D
signal boss_time

func _on_body_entered(_body):
	boss_time.emit()
