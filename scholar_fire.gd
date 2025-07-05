extends Area2D

func _ready():
	$Timer.start()

func _on_body_entered(body):
	if "hurt" in body:
		body.hurt(1, position.direction_to(body.position))


func _on_timer_timeout():
	queue_free()
