extends CharacterBody2D
var direction
var speed = 360
var bullet_path
var throw

func start(_position, _direction):
	bullet_path = _direction
	position = _position
	throw = sign(bullet_path.x) * 30
	velocity = bullet_path * speed

func _physics_process(_delta):
	move_and_slide()
	transform.x.x = sign(velocity.x)
	$AnimationPlayer.play("flying")
	
	
func _on_area_2d_body_entered(body):
	if not body.is_in_group("player"):
		if "hurt" in body:
			body.hurt(1, position.direction_to(body.position))
			queue_free()
		else:
			queue_free()


func _on_timer_timeout():
	queue_free()
