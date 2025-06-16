extends Area2D
signal Golem_time

func _on_body_entered(body):
	Golem_time.emit()
