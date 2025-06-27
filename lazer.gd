extends Node2D

@export var laser_length := 500.0
@export var damage_per_second := 10.0
@export var rotation_speed := 1.8  # radians per second

@onready var raycast = $RayCast2D
@onready var line = $Line2D

var is_active := true
var hit_available = true

func _ready():
	var initial_direction = Vector2.RIGHT.rotated(rotation)
	raycast.target_position = initial_direction * laser_length

func _process(delta):
	if not is_active:
		line.visible = false
		return

	# Rotate continuously
	rotation += rotation_speed * delta
	
	# Update direction based on new rotation
	var new_direction = Vector2.RIGHT.rotated(rotation)
	raycast.target_position = new_direction * laser_length

	update_laser(delta)

func update_laser(_delta):
	raycast.force_raycast_update()
	line.visible = true

	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		line.points = [Vector2.ZERO, to_local(hit_point)]

		var collider = raycast.get_collider()
		if collider and collider.has_method("hurt") and hit_available:
			hit_available = false
			collider.hurt(1, position.direction_to(collider.position))
			$hit_timer.start()
	else:
		line.points = [Vector2.ZERO, raycast.target_position]


func _on_hit_timer_timeout():
	hit_available = true
