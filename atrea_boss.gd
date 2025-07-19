extends CharacterBody2D
@export var lightning_attack: PackedScene
@export var scholar_lazer: PackedScene
@export var magic_fire: PackedScene
@export var magic_orb: PackedScene
enum states {IDLE, MELEE_COMBO, JUMP_LIGHTNING, JAB_ATTACK, JUMP_ATTACK, SPELL_CAST, CHASE, DEAD, HURT, SHOOT}
var state = states.IDLE
var speed = 126
var health = 18
var start_pos
var player
var start_health
var prev_state
var hit
var action_started = false
var actions = ["melee_combo", "jump_lightning", "jab_attack", "jump_attack", "spell_cast", "shoot"]
var weights = [0, 0, 0, 0, 1, 0]
#var weights = [0, 25, 0, 15, 30, 30]
var doing_run_attack1 = false
var action_wait = 2
var dead = false
var select_new_action = true
var boss_intro = false
var song_time = false
var lightning_check = false
var action_cooldown = false
var phase = 1

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
		
	if song_time and phase == 1:
		song_time = false
		await $BossMusicPhase1.finished
		$BossMusicPhase1.play()
		song_time = true
		
	var player_position = player.global_position
	var distance = global_position.distance_to(player_position)
	if distance <= 200:
		weights[0] = 40
		weights[2] = 35
		print(action_started)
	else:
		weights[0] = 0
		weights[2] = 0
	move_and_slide()
	if lightning_check:
		if global_position.distance_to(player.global_position) < 40:
			velocity = Vector2.ZERO
			
	if not action_started and not dead and not action_cooldown and phase == 1:
		action_started = true
		action_decider()
	elif not dead and action_cooldown:
		state = states.IDLE
		choose_action()
		
	if dead:
		choose_action()

func action_decider():
	var action = weighted_random_choice(actions, weights)
	if action == "shoot" and not dead:
		state = states.SHOOT
	elif action == "jab_attack" and not dead:
		state = states.JAB_ATTACK
	elif action == "spell_cast" and not dead:
		state = states.SPELL_CAST
	elif action == "jump_attack" and not dead:
		state = states.JUMP_ATTACK
	elif action == "jump_lightning" and not dead:
		state = states.JUMP_LIGHTNING
	elif action == "melee_combo" and not dead:
		state = states.MELEE_COMBO
	choose_action()

func choose_action():
	$Label.text = states.keys()[state]
	
	match state:
		states.DEAD:
			song_time = false
			$AnimationPlayer.play("death")
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
		states.SHOOT:
			shoot_attack()
		states.JAB_ATTACK:
			jab_attack()
		states.SPELL_CAST:
			spell_casting()
		states.JUMP_ATTACK:
			jump_attack()
		states.JUMP_LIGHTNING:
			jump_lightning()
		states.MELEE_COMBO:
			melee_combo()


func shoot_attack():
	velocity = Vector2.ZERO
	for i in range(randi_range(2, 8)):
		if not dead:
			$AnimationPlayer.play("projectile_attack")
			transform.x.x = sign(position.direction_to(player.position).x)
			await get_tree().create_timer(0.7).timeout
			var orb = magic_orb.instantiate()
			get_parent().add_child(orb)
			orb.global_position = global_position
			orb.global_position.y += -66
			orb.global_position.x += 40 * sign(position.direction_to(player.position).x)
			#$magic_orb.play()
			var base_dir = (player.global_position - orb.global_position).normalized()
			orb.velocity = base_dir * orb.speed
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(0.2).timeout
	action_started = false
	action_cooldown = true
	$Idle_timer.start()
	
func melee_combo():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Idle")
	await get_tree().create_timer(0.4).timeout
	transform.x.x = sign(position.direction_to(player.position).x)
	$AnimationPlayer.play("Melee_attack_combo")
	await $AnimationPlayer.animation_finished
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 2
	$Idle_timer.start()

func jump_lightning():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("jump_lightning")
	await get_tree().create_timer(0.3).timeout
	velocity = position.direction_to(player.position) * speed * 5
	lightning_check = true
	if velocity.x != 0:
		transform.x.x = sign(velocity.x)
	await get_tree().create_timer(0.8).timeout
	velocity = Vector2.ZERO
	await $AnimationPlayer.animation_finished
	lightning_check = false
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 4
	$Idle_timer.start()
	

func jump_attack():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("jump_attack")
	velocity = position.direction_to(player.position) * speed * 5
	if velocity.x != 0:
		transform.x.x = sign(velocity.x)
	await get_tree().create_timer(0.9).timeout
	velocity = Vector2.ZERO
	await $AnimationPlayer.animation_finished
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 2.5
	$Idle_timer.start()


func jab_attack():
	velocity = Vector2.ZERO
	transform.x.x = sign(position.direction_to(player.position).x)
	$AnimationPlayer.play("jab_attack")
	await $AnimationPlayer.animation_finished
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 2
	$Idle_timer.start()

func spell_casting():
	velocity = Vector2.ZERO
	for i in range(randi_range(2, 4)):
		transform.x.x = sign(position.direction_to(player.position).x)
		$AnimationPlayer.play("Spell_casting")
		await get_tree().create_timer(0.4).timeout
		var lightning = lightning_attack.instantiate()
		get_parent().add_child(lightning)
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("Idle")
		await get_tree().create_timer(0.5).timeout
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 3
	$Idle_timer.start()
	

func hurt(amount, _dir):
	if not hit:
		hit = true
		if randf() < 0.30 and state == states.IDLE:
			$AnimationPlayer.play("block")
		else:
			#$Hit.play()
			$AnimationPlayer.play("hit")
			health -= amount
			await get_tree().create_timer(0.1).timeout
			await get_tree().create_timer(0.2).timeout
			if health <= 0:
				if phase == 1:
					phase_two_set_up()
				else:
					dead = true
					state = states.DEAD
		hit = false


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
	
	
func phase_two_set_up():
	pass
	
	
func _on_boss_spawning_boss_time():
	if not boss_intro:
		boss_intro = true
		$CanvasLayer/Label.show()
		$CanvasLayer/HealthBar.show()
		var player_vars = get_node("/root/World/Level1/Player")
		player_vars.boss_position = global_position
		$BossMusicPhase1.play()
		song_time = true
		$AnimationPlayer.play("Idle")
		await get_tree().create_timer(3.8).timeout
		$CanvasLayer/Label.hide()
		set_physics_process(true)
		$CollisionShape2D.disabled = false
		state = states.IDLE
		choose_action()
	
	

func _on_first_hit_body_entered(body):
	body.hurt(1, position.direction_to(body.position))


func _on_lightning_hitbox_body_entered(body):
	body.hurt(2, position.direction_to(body.position))


func _on_idle_timer_timeout():
	action_cooldown = false
	

