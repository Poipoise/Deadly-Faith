extends Area2D
signal scholar_time

func _on_body_entered(body):
	scholar_time.emit()
