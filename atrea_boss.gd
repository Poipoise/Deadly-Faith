extends CharacterBody2D
@export var lightning_attack: PackedScene
@export var magic_orb: PackedScene
@export var pulse: PackedScene
signal Astrea_intro
signal shield_start
signal Ending
enum states {IDLE, MELEE_COMBO, JUMP_LIGHTNING, JAB_ATTACK, JUMP_ATTACK, SPELL_CAST, DEAD, HURT, SHOOT, SCREAM, DASH_COMBO, PULSE, MUD_HANDS, MONSTER_ATTACK2}
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
var weights = [0, 25, 0, 22, 28, 25]
var weights_phase2 = [0, 10, 0, 8, 10, 12, 0, 23, 20, 15, 0]
var actions_phase2 = ["melee_combo", "jump_lightning", "jab_attack", "jump_attack", "spell_cast", "shoot", "scream", "dash_combo", "pulse", "mud_hands", "monster_attack2"]
var doing_run_attack1 = false
var dead = false
var select_new_action = true
var boss_intro = false
var song_time = false
var lightning_check = false
var action_cooldown = false
var phase = 1
var broken_crystals = 0
var fight_started = false
var cutscene = false
var invincible = false
var healing = true

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
		$Idle_timer.stop()
		$BossMusicPhase1.stop()
		$BossMusicPhase2.stop()
		$CanvasLayer/HealthBar.hide()
		set_physics_process(false)
		$CollisionShape2D.disabled = true
	
	if phase == 2 and broken_crystals == 4:
		invincible = false
		
	if song_time and phase == 1:
		song_time = false
		await $BossMusicPhase1.finished
		$BossMusicPhase1.play()
		song_time = true
		
	if song_time and phase == 2:
		song_time = false
		await $BossMusicPhase2.finished
		$BossMusicPhase2.play()
		song_time = true
		
	if cutscene:
		if health != $CanvasLayer/HealthBar.max_value and healing:
			healing = false
			health += 1
			await get_tree().create_timer(0.2).timeout
			healing = true
		
	var player_position = player.global_position
	var distance = global_position.distance_to(player_position)
	if distance <= 150:
		if phase == 1:
			weights[0] = 30
			weights[2] = 30
		elif phase == 2:
			weights_phase2[0] = 15
			weights_phase2[2] = 15
			weights_phase2[10] = 20
	else:
		if phase == 1:
			weights[0] = 0
			weights[2] = 0
		elif phase == 2:
			weights_phase2[0] = 0
			weights_phase2[2] = 0
			weights_phase2[10] = 0
	move_and_slide()
	if lightning_check:
		if global_position.distance_to(player.global_position) < 40:
			velocity = Vector2.ZERO
	if not action_started and not dead and not action_cooldown and phase == 1 and not cutscene:
		action_started = true
		action_decider()
	
	elif not dead and action_cooldown and not hit and not cutscene:
		state = states.IDLE
		choose_action()
		
	if dead and not cutscene:
		choose_action()
	
	if not action_started and not dead and not action_cooldown and phase == 2 and not cutscene:
		action_started = true
		action_decider_phase2()

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
	

func action_decider_phase2():
	var action = weighted_random_choice(actions_phase2, weights_phase2)
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
	elif action == "scream" and not dead:
		state = states.SCREAM
	elif action == "dash_combo" and not dead:
		state = states.DASH_COMBO
	elif action == "pulse" and not dead:
		state = states.PULSE
	elif action == "mud_hands" and not dead:
		state = states.MUD_HANDS
	elif action == "Monster_attack2" and not dead:
		state = states.MONSTER_ATTACK2
	choose_action()

func choose_action():
	match state:
		states.DEAD:
			song_time = false
			$BossMusicPhase2.stop()
			$AnimationPlayer.play("Death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
			$CanvasLayer/HealthBar.hide()
			$BossMusicPhase1.stop()
			Ending.emit()
		states.IDLE:
			if phase == 1:
				$AnimationPlayer.play("Idle")
			elif phase > 1:
				$AnimationPlayer.play("Idle_monster")
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
		states.SCREAM:
			scream()
		states.DASH_COMBO:
			Monster_dash_combo()
		states.PULSE:
			Monster_pulse()
		states.MUD_HANDS:
			spawn_mud_hands()
		states.MONSTER_ATTACK2:
			Monster_attack2()


func shoot_attack():
	velocity = Vector2.ZERO
	for i in range(randi_range(2, 8)):
		if not dead and not cutscene:
			$AnimationPlayer.play("projectile_attack")
			transform.x.x = sign(position.direction_to(player.position).x)
			await get_tree().create_timer(0.7).timeout
			var orb = magic_orb.instantiate()
			get_parent().add_child(orb)
			orb.global_position = global_position
			orb.global_position.y += -66
			orb.global_position.x += 40 * sign(position.direction_to(player.position).x)
			var base_dir = (player.global_position - orb.global_position).normalized()
			orb.velocity = base_dir * orb.speed
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(0.2).timeout
	action_started = false
	action_cooldown = true
	$Idle_timer.start()
	
func melee_combo():
	if not dead:
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
	if not cutscene and not dead:
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
	if not cutscene and not dead:
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
	if not dead:
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
		if not dead and not cutscene:
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

func scream():
	if not dead:
		velocity = Vector2.ZERO
		transform.x.x = sign(position.direction_to(player.position).x)
		$AnimationPlayer.play("monster_scream")
		var world_vars = get_node("/root/World")
		world_vars.Astrea_summons()
		await $AnimationPlayer.animation_finished
		action_started = false
		action_cooldown = true
		$Idle_timer.wait_time = 4
		$Idle_timer.start()
		$scream_timer.start()
		weights_phase2[6] = 0

func Monster_attack2():
	if not dead:
		velocity = Vector2.ZERO
		transform.x.x = sign(position.direction_to(player.position).x)
		$AnimationPlayer.play("Monster_attack2")
		await $AnimationPlayer.animation_finished
		action_started = false
		action_cooldown = true
		$Idle_timer.wait_time = 2
		$Idle_timer.start()

func Monster_dash_combo():
	velocity = Vector2.ZERO
	for i in range(3):
		if not dead:
			$AnimationPlayer.play("Monster_attack3")
			await get_tree().create_timer(0.3).timeout
			collision_layer = (collision_layer | 0) & ~(1 << 2)
			velocity = position.direction_to(player.position) * speed * 6
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
			await $AnimationPlayer.animation_finished
			velocity = Vector2.ZERO
			collision_layer = collision_layer | (1 << 2)
			$AnimationPlayer.play("Idle_monster")
			await get_tree().create_timer(0.5).timeout
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 2
	$Idle_timer.start()

func Monster_pulse():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("monster_idle2")
	var pulse_num = randi_range(3, 6)
	for i in range(pulse_num):
		if not dead:
			var pulse = pulse.instantiate()
			pulse.position = position
			pulse.base_color = Color(0.259, 0.188, 0.325)
			get_parent().add_child(pulse)
			await get_tree().create_timer(1.5).timeout
	action_started = false
	action_cooldown = true
	$Idle_timer.wait_time = 2
	$Idle_timer.start()

func spawn_mud_hands():
	if not dead:
		velocity = Vector2.ZERO
		transform.x.x = sign(position.direction_to(player.position).x)
		$AnimationPlayer.play("Monster_attack1")
		var world_vars = get_node("/root/World")
		world_vars.Astrea_mud_hands()
		await $AnimationPlayer.animation_finished
		action_started = false
		action_cooldown = true
		$Idle_timer.wait_time = 2.5
		$Idle_timer.start()

func hurt(amount, _dir):
	if not hit:
		hit = true
		if randf() < 0.30 and state == states.IDLE:
			state = states.HURT
			choose_action()
			transform.x.x = sign(position.direction_to(player.position).x)
			$AnimationPlayer.play("block")
			await $AnimationPlayer.animation_finished
			action_started = false
		elif not invincible:
			$Hit.play()
			health -= amount
			$HitParticle.process_material.direction.y = sign (velocity.x) * -1
			$Sprite2D.material.set_shader_parameter("active", true)
			$HitParticle.emitting = true
			await get_tree().create_timer(0.1).timeout
			$HitParticle.emitting = false
			await get_tree().create_timer(0.2).timeout
			$Sprite2D.material.set_shader_parameter("active", false)
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
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	$CanvasLayer/HealthBar.show()
	$CanvasLayer/HealthBar.value = 0
	$CanvasLayer/HealthBar.max_value = 25
	cutscene = true
	
	position = Vector2(4986,889)
	var player_vars = get_node("/root/World/Level1/Player")
	player_vars.boss_position = global_position
	player.Asrea_phase_change()
	$AnimationPlayer.play("respawn")
	phase = 2
	$BossMusicPhase1.stop()
	$BossMusicPhase1.stop()
	await $AnimationPlayer.animation_finished
	state = states.IDLE
	choose_action()
	await get_tree().create_timer(2.2).timeout
	$BossMusicPhase2.play()
	song_time = true
	$AnimationPlayer.play("monster_scream")
	shield_start.emit()
	invincible = true
	await $AnimationPlayer.animation_finished
	state = states.IDLE
	choose_action()
	await get_tree().create_timer(3.3).timeout
	state = states.SCREAM
	choose_action()
	await get_tree().create_timer(1).timeout
	cutscene = false
	
	
	
	
func _on_boss_spawning_boss_time():
	if not boss_intro:
		boss_intro = true
		fight_started = true
		$CanvasLayer/Label.show()
		$CanvasLayer/HealthBar.show()
		var player_vars = get_node("/root/World/Level1/Player")
		player_vars.boss_position = global_position
		$BossMusicPhase1.play()
		song_time = true
		$AnimationPlayer.play("Idle")
		await get_tree().create_timer(5.4).timeout
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

func crystal_broken():
	broken_crystals += 1
	

func respawn():
	if not dead:
		state = states.IDLE
		set_physics_process(false)
		$CollisionShape2D.disabled = true
		position = start_pos
		health = start_health
		action_started = false
		select_new_action = true
		doing_run_attack1 = false
		lightning_check = false
		dead = false
		boss_intro = false
		state = states.IDLE
		if phase == 1 and fight_started:
			weights = [0, 25, 0, 22, 28, 25]
			await get_tree().create_timer(0.4).timeout
			Astrea_intro.emit()
			_on_boss_spawning_boss_time()
		if phase == 2:
			invincible = false
			broken_crystals = 0
			weights_phase2 = [0, 10, 0, 8, 10, 12, 0, 23, 20, 15, 0]
			await get_tree().create_timer(0.4).timeout
			var world_vars = get_node("/root/World")
			world_vars.Boss_Music_Time()
			phase_two_set_up()


func _on_scream_timer_timeout():
	weights_phase2[6] = 8
