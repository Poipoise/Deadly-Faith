extends CharacterBody2D
@export var speed = 330.0


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	self.rotation = velocity.angle()

func _on_area_2d_body_entered(body):
	if "hurt" in body:
		$AnimationPlayer.play("hit")
		body.hurt(1, position.direction_to(body.position))
		await $AnimationPlayer.animation_finished
		queue_free()


func _on_timer_timeout():
	queue_free()
