extends CharacterBody2D

var direction
var speed = 350
var bullet_path
var throw
# Called when the node enters the scene tree for the first time.
func start(_position, _direction):
	bullet_path = _direction
	position = _position
	position.y += -40
	throw = sign(bullet_path.x) * 30
	position.x += throw
	velocity = bullet_path * speed
	$AnimationPlayer.play("flying")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide()
	transform.x.x = sign(velocity.x)
	
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		pass
	else:
		$AnimationPlayer.play("Hit")
		await $AnimationPlayer.animation_finished
		queue_free()
		body.hurt(1, position.direction_to(body.position))


func _on_timer_timeout():
	queue_free()
