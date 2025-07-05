extends CharacterBody2D
@export var projectile_scene: PackedScene
@export var pulse: PackedScene
@export var lazer: PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
enum states {IDLE, SHOOTING, ATTACK, DEAD, HURT, PULSE, BEAM, SHIELD, UNSHIELD}
var state = states.IDLE
var health = 15
var start_pos
var start_health
var prev_state
var hit
var action_started = false
var actions = ["Shooting", "Attack", "Pulse", "Beam", "shield", "Unshield"]
var weights = [27, 0, 19, 27, 27, 0]
var action_wait = 2
var dead = false
var shield1 = false
var boss_intro = false
var song_time = false
func _ready():
	start_pos = position
	start_health = health
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$CanvasLayer/HealthBar.value = health
	
func _physics_process(delta):
	$CanvasLayer/HealthBar.value = health
	if $"../Player".game_over:
		$BossMusic.stop()
		$CanvasLayer/HealthBar.hide()
		set_physics_process(false)
		$CollisionShape2D.disabled = true
	
	if song_time:
		song_time = false
		await $BossMusic.finished
		$BossMusic.play()
		song_time = true
		
	var player_position = $"../Player".global_position
	var distance = global_position.distance_to(player_position)
	if distance <= 80:
		weights[1] = 80
	else:
		weights[1] = 0
	move_and_slide()
	if not action_started and not dead:
		action_started = true
		state = states.IDLE
		choose_action(delta)
		await get_tree().create_timer(action_wait).timeout
		var action = weighted_random_choice(actions, weights)
		if action == "Shooting" and not dead:
			state = states.SHOOTING
		elif action == "Attack" and not dead:
			state = states.ATTACK
		elif action == "Pulse" and not dead:
			state = states.PULSE
		elif action == "Beam" and not dead:
			state = states.BEAM
		elif action == "shield" and not dead:
			state = states.SHIELD
		elif action == "Unshield" and not dead:
			state = states.UNSHIELD
		choose_action(delta)
	if dead:
		choose_action(delta)
	
func choose_action(delta):
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
		states.SHOOTING:
			shoot_attack(delta)
		states.ATTACK:
			Melee_attack(delta)
		states.PULSE:
			pulse_state(delta)
		states.BEAM:
			lazer_attack(delta)
		states.SHIELD:
			shield(delta)
		states.UNSHIELD:
			unshield(delta)
	
func hurt(amount, _dir):
	if not hit:
		hit = true
		$Hit.play()
		health -= amount
		prev_state = state
		state = states.HURT
		$HitParticle.process_material.direction.y = sign (velocity.x) * -1
		$Sprite2D.material.set_shader_parameter("active", true)
		$HitParticle.emitting = true
		await get_tree().create_timer(0.1).timeout
		#$HitParticle.emitting = false
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.material.set_shader_parameter("active", false)
		hit = false
		state = prev_state
		if health <= 0:
			dead = true
			state = states.DEAD

func pulse_state(_delta):
	action_started = true
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Idle")
	await get_tree().create_timer(0.1).timeout
	var pulse_num = randi_range(3, 6)
	for i in range(pulse_num):
		if not dead:
			$AnimationPlayer.play("Body_glow")
			$Golem_pulse.play()
			await get_tree().create_timer(0.3).timeout
			var pulse = pulse.instantiate()
			pulse.position = position
			Level1.add_child(pulse)
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(0.8).timeout
	action_wait = 2
	action_started = false

func Melee_attack(_delta):
	action_started = true
	var player = $"../Player"
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Melee_attack")
	transform.x.x = sign(position.direction_to(player.position).x)
	await get_tree().create_timer(0.3).timeout
	$Golem_melee.play()
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(0.3).timeout
	action_wait = 2
	action_started = false
	
func shoot_attack(_delta):
	action_started = true
	var player = $"../Player"
	velocity = Vector2.ZERO
	for i in range(randi_range(1, 3)):
		if not dead:
			$AnimationPlayer.play("arm_cannon")
			await get_tree().create_timer(0.8).timeout
			$shot_sound.play()
			var base_dir = (player.global_position - global_position).normalized()
			var angles = [0, deg_to_rad(10), deg_to_rad(-10)]
			for angle in angles:
				var projectile = projectile_scene.instantiate()
				get_parent().add_child(projectile)
				projectile.global_position = global_position
				var spread_dir = base_dir.rotated(angle)
				projectile.velocity = spread_dir * projectile.speed
				projectile.rotation = spread_dir.angle()
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(0.4).timeout
	action_wait = 1
	action_started = false
	
func lazer_attack(_delta):
	action_started = true
	var timer = randi_range(4, 6)
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Face_glow")
	$lazer_charging.play()
	await get_tree().create_timer(0.9).timeout
	$lazer_charging.stop()
	$lazer_burst.play()
	var lazer = lazer.instantiate()
	Level1.add_child(lazer)
	lazer.position = position
	lazer.position.y -= 37
	lazer.position.x += 2
	await get_tree().create_timer(timer).timeout
	lazer.queue_free()
	action_wait = 2
	action_started = false
	
func shield(_delta):
	action_started = true
	action_wait = 1
	velocity = Vector2.ZERO
	$AnimationPlayer.play("armor")
	weights[4] = 0
	$Golem_shield.play()
	collision_layer = (collision_layer | (1 << 4)) & ~(1 << 2)
	$shield_timer.start()
	await $AnimationPlayer.animation_finished
	if shield1:
		action_wait = 4
	
	action_started = false
	

func _on_shield_timer_timeout():
	weights[5] = 100
	
	
func unshield(_delta):
	if not dead:
		action_started = true
		collision_layer = (collision_layer | ~(1 << 4)) & (1 << 2)
		$AnimationPlayer.play("de_armor")
		weights[5] = 0
		await get_tree().create_timer(0.6).timeout
		$Golem_unshield.play()
		await $AnimationPlayer.animation_finished
	action_wait = 2
	action_started = false


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


func _on_boss_spawning_boss_time():
	if not boss_intro:
		boss_intro = true
		$CanvasLayer/Label.show()
		$CanvasLayer/HealthBar.show()
		var player_vars = get_node("/root/World/Level1/Player")
		player_vars.boss_position = global_position
		$BossMusic.play()
		song_time = true
		$AnimationPlayer.play("Spawning")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("Idle")
		await get_tree().create_timer(3.8).timeout
		$CanvasLayer/Label.hide()
		set_physics_process(true)
		$CollisionShape2D.disabled = false
		state = states.IDLE


func respawn():
	state = states.IDLE
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	position = start_pos
	health = start_health
	action_started = false
	weights = [27, 0, 19, 27, 27, 0]
	action_wait = 2
	dead = false
	shield1 = false
	boss_intro = false
	state = states.IDLE


func _on_melee_collision_body_entered(body):
	body.hurt(1, position.direction_to(body.position))
