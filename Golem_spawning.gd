extends Area2D
signal Golem_time

func _on_body_entered(_body):
	print("Golem scene emitted")
	Golem_time.emit()
