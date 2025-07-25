extends CharacterBody2D
@export var projectile : PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
var speed = 140
enum states {IDLE, CHASE, ATTACK, DEAD, HURT, RUN, JUMP}
var state = states.IDLE
var player
var attacking = false
var health = 5
var player_pos
var shoot_direction
var start_pos
var start_health
var hit
var prev_state
var jumping
var dead = false
var jump_interupt = false
var invincible = false

func _ready():
	start_pos = position
	start_health = health
func _physics_process(_delta):
	choose_action()
	move_and_slide()
	if health <= 0 and not dead:
		dead = true
		state = states.DEAD
	
func choose_action():
	match state:
		states.DEAD:
			$Death.play()
			$AnimationPlayer.play("Death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("Idle")
			velocity = Vector2.ZERO
		states.CHASE:
			if not attacking:
				$AnimationPlayer.play("Walking")
				velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACK:
			velocity = Vector2.ZERO
			shoot_direction = position.direction_to(player.position)
			transform.x.x = sign(shoot_direction.x)
			if not attacking and not jump_interupt:
				$AnimationPlayer.play("MoneyBagThrow")
				attacking = true
				await get_tree().create_timer(0.4).timeout
				$Throw.play()
				var Projectile = projectile.instantiate()
				Projectile.start(position, shoot_direction)
				Level1.add_child(Projectile)
				$AttackTimer.start()
		states.RUN:
			if not attacking:
				invincible = false
				$AnimationPlayer.play("BackwardsWalking")
				velocity = position.direction_to(player.position) * speed * 0.9 * -1
				if velocity.x != 0:
					transform.x.x = sign(velocity.x) * -1
		states.JUMP:
			velocity = Vector2.ZERO
			if not jumping and not dead:
				perform_jump()
						


func hurt(amount, dir):
	if not hit and not invincible:
		hit = true
		$Hit.play()
		health -= amount
		prev_state = state
		state = states.HURT
		velocity = dir * 100
		$Sprite2D.material.set_shader_parameter("active", true)
		$AnimationPlayer.play("Damage")
		$HitParticle.emitting = true
		await get_tree().create_timer(0.1).timeout
		$HitParticle.emitting = false
		await get_tree().create_timer(0.5).timeout
		$Sprite2D.material.set_shader_parameter("active", false)
		hit = false
		state = prev_state
		if health <= 0:
			state = states.DEAD

func _on_detect_body_entered(body):
	player = body
	state = states.CHASE

func _on_detect_body_exited(_body):
	state = states.IDLE


func _on_attack_body_entered(_body):
		state = states.ATTACK
		
func _on_attack_body_exited(_body):
	prev_state = states.CHASE
	state = states.CHASE
	
func _on_attack_timer_timeout():
	attacking = false


func _on_walk_away_body_entered(_body):
	state = states.RUN
	$Run_timer.start()


func _on_walk_away_body_exited(_body):
	prev_state = states.ATTACK
	state = states.ATTACK
	$Run_timer.stop()

func respawn():
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	position = start_pos
	health = start_health
	await get_tree().create_timer(0.1).timeout
	state = states.IDLE
	player = null
	dead = false
	jump_interupt = false
	invincible = false


func _on_run_timer_timeout():
	jumping = false
	state = states.JUMP


func perform_jump():
	jumping = true
	jump_interupt = true

	var area: Area2D = $Detect
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var shape := collision_shape.shape as CircleShape2D
	var area_position: Vector2 = area.global_position
	var radius: float = shape.radius

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var jumped: bool = false

	for i in range(30):
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(0.0, radius)
		var offset := Vector2(cos(angle), sin(angle)) * distance
		var random_position: Vector2 = area_position + offset

		var player_distance_limit: float = ($WalkAway.get_node("CollisionShape2D").shape as CircleShape2D).radius
		if random_position.distance_to(player.global_position) < player_distance_limit:
			continue

		var point_query := PhysicsPointQueryParameters2D.new()
		point_query.position = random_position
		point_query.collision_mask = 1
		var point_result := space_state.intersect_point(point_query)
		if point_result.size() > 0:
			continue

		var ray_query := PhysicsRayQueryParameters2D.new()
		ray_query.from = global_position
		ray_query.to = random_position
		ray_query.exclude = [self]
		ray_query.collision_mask = 1
		var ray_result := space_state.intersect_ray(ray_query)
		if ray_result:
			continue

		# Jump!
		jumped = true
		invincible = true
		$AnimationPlayer.play("Jump")
		await $AnimationPlayer.animation_finished

		self.visible = false
		await get_tree().create_timer(2.0).timeout
		global_position = random_position
		self.visible = true

		$AnimationPlayer.play("Landing")
		await $AnimationPlayer.animation_finished

		invincible = false
		jump_interupt = false
		state = states.ATTACK
		jumping = false
		return

# If no valid location found after 30 tries
	if not jumped and not dead:
		$Run_timer.start()
		jump_interupt = false
		state = states.RUN
		jumping = false
