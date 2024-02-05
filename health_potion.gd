extends StaticBody2D


func _on_area_2d_body_entered(body):
	body.health = 5
	body.health_change()
	queue_free()
