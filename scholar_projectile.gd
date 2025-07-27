extends CharacterBody2D
@export var speed = 350.0

func _ready():
	$Timer.start()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		
	self.rotation = velocity.angle()


func _on_area_2d_body_entered(body):
	if "hurt" in body:
		body.hurt(1, position.direction_to(body.position))
		queue_free()


func _on_timer_timeout():
	queue_free()
