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
				$AnimationPlayer.play("BackwardsWalking")
				velocity = position.direction_to(player.position) * speed * 0.9 * -1
				if velocity.x != 0:
					transform.x.x = sign(velocity.x) * -1
		states.JUMP:
			while not jumping and not dead:
				jumping = true
				jump_interupt = true
				var area = $Detect
				var collision_shape = area.get_node("CollisionShape2D")
				var shape = collision_shape.shape
				var area_position = area.global_position
				var random_position : Vector2
				var radius = shape.radius
				var raycast : RayCast2D = $RayCast2D
				var jumped = false
				var space_state = get_world_2d().direct_space_state
				raycast.global_position = global_position
				if not attacking and not dead:
					for i in range(30):
						random_position = area_position + Vector2(
							randi_range(-radius, radius),
							randi_range(-radius, radius)
						)
						var radius2 = $WalkAway/CollisionShape2D.shape.radius  
						if random_position.distance_to(player.global_position) < radius2:
							continue 
						var query = PhysicsPointQueryParameters2D.new()
						query.position = random_position
						query.collision_mask = 1  
						var result = space_state.intersect_point(query)
						if result.size() > 0:
							continue
						
						
						raycast.look_at(random_position)  
						raycast.force_raycast_update()  
						var ray_query = PhysicsRayQueryParameters2D.create(global_position, random_position)
						var ray_result = space_state.intersect_ray(ray_query)
						if ray_result:
							continue
						
						jumped = true
						$CollisionShape2D.disabled = true
						$AnimationPlayer.play("Jump")
						await $AnimationPlayer.animation_finished
						self.visible = false
						await get_tree().create_timer(2).timeout
						global_position = random_position
						self.visible = true
						$AnimationPlayer.play("Landing")
						await $AnimationPlayer.animation_finished
						$CollisionShape2D.disabled = false
						# If there’s no collision at the random position, teleport there
						jump_interupt = false
						state = states.ATTACK
						break
					if not jumped and not dead:
						$Run_timer.start()
						jump_interupt = false
						state = states.RUN
						


func hurt(amount, dir):
	if not hit:
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


func _on_run_timer_timeout():
	jumping = false
	state = states.JUMP
