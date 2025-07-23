extends Area2D

func _ready():
	$AnimationPlayer.play("appear")
	await $AnimationPlayer.animation_finished
	$CollisionShape2D.disabled = false
	$Timer.start()
	$AnimationPlayer.play("Idle")
	

func _on_timer_timeout():
	$CollisionShape2D.disabled = true
	$AnimationPlayer.play("disappear")
	await $AnimationPlayer.animation_finished
	queue_free()



func _on_body_entered(body):
	if "hurt" in body:
		body.hurt(1, position.direction_to(body.position))
