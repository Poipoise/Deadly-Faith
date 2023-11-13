extends CharacterBody2D

signal health_changed

@export var invincible = false
@export var roll_speed = 250
var run_speed = 125
var sprint_speed = 250
var attacking = false
var health = 5
enum states {IDLE, MOVING, ATTACKING, DEAD, HURT, ROLLING}
var state = states.IDLE
var input
var rolling = false
var stamina = 100:
	set = set_stamina
var stamina_empty = true
var recharging = false
var stamina_depletion = .5
var attack_number = 0

func _physics_process(delta):
	choose_action()
	if stamina == 0 && stamina_empty:
		stamina_check()
	input = Input.get_vector("left", "right", "up", "down")
	
	if recharging:
		if stamina < 100:
			stamina = stamina + stamina_depletion
		else:
			recharging = false
	
	if attacking:
		$AnimationPlayer.speed_scale = 1
		velocity = Vector2.ZERO
	elif state == states.ROLLING:
		$AnimationPlayer.speed_scale = 1
		velocity = input * roll_speed
	elif Input.is_action_pressed("sprint"):
		if stamina > 0:
			$RunParticles.amount = 20
			$RunParticles.process_material.initial_velocity_min = 50
			$RunParticles.process_material.initial_velocity_max = 100
			recharging = false
			$AnimationPlayer.speed_scale = 2
			velocity = input * sprint_speed
			stamina = stamina - stamina_depletion
		else:
			$RunParticles.amount = 4
			$RunParticles.process_material.initial_velocity_min = 50
			$RunParticles.process_material.initial_velocity_max = 100
			$AnimationPlayer.speed_scale = 1
			velocity = input * run_speed
	else:
		$RunParticles.amount = 4
		$RunParticles.process_material.initial_velocity_min = 50
		$RunParticles.process_material.initial_velocity_max = 100
		$AnimationPlayer.speed_scale = 1
		velocity = input * run_speed
	
	if not attacking and not rolling:
		if velocity.length() > 0:
				state = states.MOVING
		if velocity.length() == 0:
				state = states.IDLE
	if velocity.x != 0:
		transform.x.x = sign(velocity.x) 
	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("attack") && not attacking && stamina >= 10:
		state = states.ATTACKING
		recharging = false
		attack_number += 1
		stamina = stamina - 10
	if event.is_action_pressed("roll") && stamina >= 15 && not rolling:
		rolling = false
		recharging = false
		state = states.ROLLING
		stamina = stamina - 15
		
func choose_action():
	$StateLabel.text = states.keys()[state]
	match state:
		states.DEAD:
			$AnimationPlayer.play("death")
			set_physics_process(false)
			velocity = Vector2.ZERO
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("Idle")
		states.MOVING:
			$AnimationPlayer.play("run")
			if velocity.x != 0:
				transform.x.x = sign(velocity.x) 
		states.ATTACKING:
			attacking = true
			if (attack_number % 2) == 1:
				$AnimationPlayer.play("attack1")
				await $AnimationPlayer.animation_finished
			else: 
				$AnimationPlayer.play("attack2")
				await $AnimationPlayer.animation_finished
			attacking = false
			if velocity.length() > 0:
				state = states.MOVING
			if velocity.length() == 0:
				state = states.IDLE
		states.ROLLING:
			rolling = true
			$AnimationPlayer.play("Roll")
			await $AnimationPlayer.animation_finished
			rolling = false
			if velocity.length() > 0:
				state = states.MOVING
			if velocity.length() == 0:
				state = states.IDLE
func die():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("death")

func hurt(amount, dir):
	if not rolling:
		var prev_state = state
		state = states.HURT
		health -= amount
		health_changed.emit(health)
		velocity = dir * 100
		await get_tree().create_timer(0.2).timeout
		state = prev_state
		if health <= 0:
			state = states.DEAD
			
func stamina_check():
	stamina_empty = false
	$EmptyStaminaCooldown.start()
	await $EmptyStaminaCooldown.timeout
	stamina_empty = true

func set_stamina(val):
	stamina = val
	if not rolling or not attacking:
		$StaminaCooldown.start()

func _on_empty_stamina_cooldown_timeout():
	print("recharging")
	recharging = true

func _on_stamina_cooldown_timeout():
	recharging = true


func _on_hurtbox_body_entered(body):
	print("attacked!")
	body.hurt(1, position.direction_to(body.position))
