extends CharacterBody2D

var direction
var speed = 400
var bullet_path
var throw
var hit = true
# Called when the node enters the scene tree for the first time.
func start(_position, _direction):
	bullet_path = _direction
	position.x = _position.x
	position.y = _position.y
	position.y += -15
	throw = sign(bullet_path.x) * 30
	position.x += throw
	velocity = bullet_path * speed
	$AnimationPlayer.play("flying")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	move_and_slide()
	transform.x.x = sign(velocity.x)
	
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		pass
	else:
		$AnimationPlayer.play("Hit")
		if body.is_in_group("player"):
			body.hurt(1, position.direction_to(body.position))
		queue_free()


func _on_timer_timeout():
	queue_free()

func destroy():
	queue_free()
