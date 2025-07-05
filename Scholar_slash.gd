extends Area2D
@export var speed := 270.0
var velocity := Vector2.ZERO

func _process(delta):
	position += velocity * delta
	transform.x.x = sign(velocity.x)

func _on_body_entered(body):
	if "hurt" in body:
		body.hurt(1, position.direction_to(body.position))
		queue_free()
	else:
		queue_free()
