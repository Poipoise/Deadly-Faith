extends CharacterBody2D
@export var speed = 300.0
@export var bounce = true

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision and bounce:
		velocity = velocity.bounce(collision.get_normal())
	elif collision:
		queue_free()
		
	self.rotation = velocity.angle()


func _on_area_2d_body_entered(body):
	if "hurt" in body:
		body.hurt(1, position.direction_to(body.position))
		queue_free()


func _on_timer_timeout():
	queue_free()
