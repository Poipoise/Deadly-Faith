extends Area2D

@export var max_radius := 250.0
@export var grow_speed := 65.0
@export var segments := 64
@export var thickness := 6.0
@export var base_color := Color(1, 1, 1)


var current_radius := 0.0

func _ready():
	randomize()
	$Line2D.width = thickness
	$Line2D.default_color = base_color

	# Create a new, non-shared shape
	var circle_shape = CircleShape2D.new()
	$CollisionShape2D.shape = circle_shape

	update_ring()
	update_collision()

func _process(delta):
	if current_radius < max_radius:
		current_radius += grow_speed * delta
		var progress = current_radius / max_radius
		var alpha = lerp(1.0, 0.0, progress)  # Fade out
		var faded_color = Color(base_color.r, base_color.g, base_color.b, alpha)
		$Line2D.default_color = faded_color
		update_ring()
		update_collision()
	
	if current_radius >= max_radius:
		queue_free()

func update_ring():
	var points = []
	for i in range(segments + 1):
		var angle = TAU * float(i) / float(segments)
		var x = cos(angle) * current_radius
		var y = sin(angle) * current_radius
		points.append(Vector2(x, y))
	$Line2D.points = points

func update_collision():
	var circle_shape = $CollisionShape2D.shape as CircleShape2D
	if circle_shape:
		circle_shape.radius = current_radius


func _on_body_entered(body):
	body.hurt(1, position.direction_to(body.position))
