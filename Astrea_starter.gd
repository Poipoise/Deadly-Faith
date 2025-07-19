extends Area2D
signal Astrea_time

func _on_body_entered(body):
	Astrea_time.emit()
	$CollisionPolygon2D.set_deferred("disabled", true)
