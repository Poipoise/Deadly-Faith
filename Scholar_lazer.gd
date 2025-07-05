extends Node2D

@export var laser_length := 110.0
@export var direction := Vector2(1, 0.7).normalized()
var hit_available = true

func _ready():
	$RayCast2D.target_position = direction.normalized() * laser_length
	check_hit()


func _process(delta):
	# Draw the laser visually
	$Line2D.points = [Vector2.ZERO, direction.normalized() * laser_length]
	check_hit()

func check_hit():
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider.has_method("hurt"):
			hit_available = false
			collider.hurt(1, position.direction_to(collider.position))
			$hit_timer.start()


func _on_hit_timer_timeout():
	hit_available = true
