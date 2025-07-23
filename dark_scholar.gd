extends CharacterBody2D
@export var slash_projectile: PackedScene
@export var scholar_lazer: PackedScene
@export var magic_fire: PackedScene
@export var magic_orb: PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
signal scholar_death
enum states {IDLE, ATTACK1, ATTACK2, CHASE, DEAD, HURT, DASH, RUN_ATTACK1, RUN_ATTACK2, SHOOT}
var state = states.IDLE
var speed = 126
var health = 18
var start_pos
var player
var start_health
var prev_state
var hit
var action_started = false
var actions = ["Attack1", "Attack2", "run_attack1", "run_attack2", "shoot"]
#var weights = [0, 0, 0, 25, 0]
var weights = [30, 0, 15, 25, 30]
var doing_run_attack1 = false
var action_wait = 1.8
var dead = false
var select_new_action = true
var boss_intro = false
var song_time = false
var invincible = false


func _ready():
	start_pos = position
	start_health = health
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$CanvasLayer/HealthBar.value = health
	player = $"../Player"
	
func _physics_process(delta):
	$CanvasLayer/HealthBar.value = health
	if player.game_over:
		$BossMusic.stop()
		$CanvasLayer/HealthBar.hide()
		set_physics_process(false)
		$CollisionShape2D.disabled = true
		
	if song_time:
		song_time = false
		await $BossMusic.finished
		$BossMusic.play()
		song_time = true
		
	var player_position = player.global_position
	var distance = global_position.distance_to(player_position)
	if distance <= 200:
		weights[1] = 35
	else:
		weights[1] = 0
	move_and_slide()
	
	if not action_started and not dead:
		state = states.CHASE
		choose_action()
		if select_new_action and not dead:
			select_new_action = false
			var action = weighted_random_choice(actions, weights)
			if (action == "Attack1" or action == "Attack2") and distance < 200 and state != states.DASH:
				action_started = true
				if action == "Attack1":
					state = states.ATTACK1
				elif action == "Attack2":
					state = states.ATTACK2
				choose_action()
			elif state != states.DASH and not dead:
				await get_tree().create_timer(action_wait).timeout
				action_started = true
				if action == "run_attack1" and not dead:
					state = states.RUN_ATTACK1
				elif action == "run_attack2" and not dead:
					state = states.RUN_ATTACK2
				elif action == "Attack2" and not dead:
					state = states.ATTACK2
				elif action == "Attack1" and not dead:
					state = states.ATTACK1
				elif action == "shoot" and not dead:
					state = states.SHOOT
				choose_action()
	if dead:
		choose_action()
	
	if state == states.RUN_ATTACK1 and velocity != Vector2.ZERO and not doing_run_attack1:
		doing_run_attack1 = true
		var fire = magic_fire.instantiate()
		Level1.add_child(fire)
		fire.position = position
		$placing_fire.play()
		await get_tree().create_timer(0.3).timeout
		doing_run_attack1 = false

func choose_action():
	$Label.text = states.keys()[state]
	
	match state:
		states.DEAD:
			song_time = false
			$AnimationPlayer.play("Death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
			await $AnimationPlayer.animation_finished
			$CanvasLayer/HealthBar.hide()
			$BossMusic.stop()
			await get_tree().create_timer(2.5).timeout
			var world_vars = get_node("/root/World")
			world_vars.play = true
			world_vars.go = true
		states.IDLE:
			$AnimationPlayer.play("Idle")
			velocity = Vector2.ZERO
			await get_tree().create_timer(0.4).timeout
			select_new_action = true
			action_started = false
		states.ATTACK2:
			attack2()
		states.ATTACK1:
			attack1()
		states.CHASE:
			$AnimationPlayer.play("walk")
			velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.RUN_ATTACK1:
			action_started = true
			$AnimationPlayer.play("run1")
			velocity = Vector2.RIGHT * speed * 3.8
			await get_tree().create_timer(1.2).timeout
			velocity = Vector2(-1 * cos(deg_to_rad(36)), sin(deg_to_rad(36))) * speed * 4
			transform.x.x = sign(velocity.x)
			await get_tree().create_timer(1.2).timeout
			velocity = Vector2(cos(deg_to_rad(72)), -1 * sin(deg_to_rad(72))) * speed * 4
			transform.x.x = sign(velocity.x)
			await get_tree().create_timer(1.2).timeout
			velocity = Vector2(cos(deg_to_rad(72)), sin(deg_to_rad(72))) * speed * 4
			transform.x.x = sign(velocity.x)
			await get_tree().create_timer(1.2).timeout
			velocity = Vector2(-1 * cos(deg_to_rad(36)), -1 * sin(deg_to_rad(36))) * speed * 4
			transform.x.x = sign(velocity.x)
			await get_tree().create_timer(1.2).timeout
			if not dead:
				state = states.IDLE
				choose_action()
			await get_tree().create_timer(0.9).timeout
		states.DASH:
			action_started = true
			invincible = true
			velocity = position.direction_to(player.position) * speed * 5 * -1
			$AnimationPlayer.play("dash")
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
			await get_tree().create_timer(0.6).timeout
			invincible = false
			if not dead:
				state = states.IDLE
				choose_action()
		states.RUN_ATTACK2:
			action_started = true
			velocity = Vector2.ZERO
			$AnimationPlayer.play("Idle")
			$lazer_charge.play()
			await get_tree().create_timer(0.5).timeout
			$lazer_charge.stop()
			$lazer_burst.play()
			if position.direction_to(player.position) < Vector2.ZERO:
				velocity = Vector2.LEFT * speed * 3.5
			elif position.direction_to(player.position) > Vector2.ZERO:
				velocity = Vector2.RIGHT * speed * 3.5
			else:
				velocity = Vector2.LEFT * speed * 3.5
			$AnimationPlayer.play("run2")
			collision_layer = (collision_layer | 0) & ~(1 << 2)
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
			var lazer = scholar_lazer.instantiate()
			lazer.direction = Vector2(1, 0.7).normalized() 
			add_child(lazer)
			lazer.global_position = global_position
			lazer.global_position.y -= 120
			lazer.global_position.x += 25 * sign(velocity.x)
			var lazer2 = scholar_lazer.instantiate()
			lazer2.direction = Vector2(0.3, 0.7).normalized() 
			add_child(lazer2)
			lazer2.global_position = global_position
			lazer2.global_position.y -= 120
			lazer2.global_position.x += 25 * sign(velocity.x)
			await get_tree().create_timer(1.3).timeout
			lazer.queue_free()
			lazer2.queue_free()
			collision_layer = collision_layer | (1 << 2)
			if not dead:
				state = states.IDLE
				choose_action()
		states.SHOOT:
			shoot_attack()
			

func _input(event):
	if (event.is_action_pressed("attack") or event.is_action_pressed("Fireball")) and randf() < 0.15 and (state == states.CHASE or state == states.CHASE):
		state = states.DASH
		choose_action()

func attack1():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Idle")
	await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("Attack1")
	$atttack1.play()
	transform.x.x = sign(position.direction_to(player.position).x)
	await get_tree().create_timer(0.1).timeout
	
	var projectile = slash_projectile.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	projectile.global_position.x += 180 * sign(position.direction_to(player.position).x)
	var base_dir = (projectile.global_position - global_position).normalized()
	projectile.velocity = base_dir * projectile.speed
	await $AnimationPlayer.animation_finished
	if not dead:
		state = states.IDLE
		choose_action()

func attack2():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Idle")
	await get_tree().create_timer(0.3).timeout
	$AnimationPlayer.play("Attack2")
	$attack2.play()
	transform.x.x = sign(position.direction_to(player.position).x)
	await $AnimationPlayer.animation_finished
	if not dead:
		state = states.IDLE
		choose_action()

func shoot_attack():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Idle")
	for i in range(randi_range(1, 5)):
		if not dead:
			transform.x.x = sign(position.direction_to(player.position).x)
			var orb = magic_orb.instantiate()
			get_parent().add_child(orb)
			orb.global_position = global_position
			orb.global_position.y -= 120
			$magic_orb.play()
			var base_dir = (player.global_position - orb.global_position).normalized()
			orb.velocity = base_dir * orb.speed
			await get_tree().create_timer(0.5).timeout
	if not dead:
		state = states.IDLE
		choose_action()


func hurt(amount, _dir):
	if not hit and not invincible:
		hit = true
		$Hit.play()
		health -= amount
		$HitParticle.process_material.direction.y = sign (velocity.x) * -1
		$Sprite2D.material.set_shader_parameter("active", true) 
		$HitParticle.emitting = true
		await get_tree().create_timer(0.1).timeout
		$HitParticle.emitting = false
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.material.set_shader_parameter("active", false)
		hit = false
		if health <= 0:
			dead = true
			scholar_death.emit()
			state = states.DEAD


func weighted_random_choice(options: Array, weights: Array) -> Variant:
	var total = 0
	for weight in weights:
		total += weight

	var rand = randi() % total
	var running_sum = 0

	for i in options.size():
		running_sum += weights[i]
		if rand < running_sum:
			return options[i]

	return options[-1]
	


func _on_area_2d_body_entered(body):
	body.hurt(1, position.direction_to(body.position))


func _on_boss_spawning_boss_time():
	if not boss_intro:
		boss_intro = true
		$CanvasLayer/Label.show()
		$CanvasLayer/HealthBar.show()
		var player_vars = get_node("/root/World/Level1/Player")
		player_vars.boss_position = global_position
		$BossMusic.play()
		song_time = true
		$AnimationPlayer.play("Idle")
		await get_tree().create_timer(5).timeout
		$CanvasLayer/Label.hide()
		set_physics_process(true)
		$CollisionShape2D.disabled = false
		state = states.CHASE


func respawn():
	state = states.IDLE
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	position = start_pos
	health = start_health
	action_started = false
	weights = [30, 0, 15, 25, 30]
	action_wait = 2
	dead = false
	boss_intro = false
	doing_run_attack1 = false
	select_new_action = true
	song_time = false
	invincible = false
	state = states.IDLE
