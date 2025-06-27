extends CharacterBody2D
var speed = 90
enum states {IDLE, CHASE, ATTACK, DEAD, HURT, DASH}
var state = states.IDLE
var start_pos
var start_health
var health = 10
var prev_state
var attacking
var hit
var player
var dash_direction = ""
var dashing
var stun = false

func _ready():
	start_pos = position
	start_health = health

func _physics_process(_delta):
	choose_action()
	move_and_slide()
	
func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			$AnimationPlayer.play("Death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
			await $AnimationPlayer.animation_finished
		states.IDLE:
			$AnimationPlayer.play("Idlefront")
			velocity = Vector2.ZERO
		states.CHASE:
			$AnimationPlayer.play("walk")
			velocity = position.direction_to(player.position) * speed
		states.ATTACK:
			if not attacking:
				#$Growl.play()
				velocity = Vector2.ZERO
				attacking = true
				$AnimationPlayer.play("fireattack")
				await $AnimationPlayer.animation_finished
				await get_tree().create_timer(0.5).timeout
				attacking = false
		states.DASH:
			if stun:
				velocity = Vector2.ZERO
				$AnimationPlayer.play("Idlefront")
			else:
				if not dashing:
					dashing = true
					velocity = Vector2.ZERO
					if dash_direction == "left":
						$AnimationPlayer.play("Dashleft")
						await get_tree().create_timer(0.3).timeout
						velocity.x -= 1 * speed * 8
					if dash_direction == "right":
						$AnimationPlayer.play("Dashright")
						await get_tree().create_timer(0.3).timeout
						velocity.x = 1 * speed * 8
					if dash_direction == "up":
						$AnimationPlayer.play("DashBack")
						await get_tree().create_timer(0.3).timeout
						velocity.y = -1 * speed * 8
					if dash_direction == "down":
						$AnimationPlayer.play("DashFront")
						await get_tree().create_timer(0.3).timeout
						velocity.y = 1 * speed * 8
					await get_tree().create_timer(0.7).timeout
					$AnimationPlayer.play("Idlefront")
					velocity.x = 0
					velocity.y = 0
					dashing = false
					stun = true
					$StunTimer.start()

func hurt(amount, dir):
	if not hit:
		hit = true
		$Hit.play()
		health -= amount
		prev_state = state
		state = states.HURT
		velocity = dir * 100
		$HitParticle.process_material.direction.y = sign (velocity.x) * -1
		$Sprite2D.material.set_shader_parameter("active", true)
		$HitParticle.emitting = true
		await get_tree().create_timer(0.1).timeout
		$HitParticle.emitting = false
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.material.set_shader_parameter("active", false)
		hit = false
		state = prev_state
		if health <= 0:
			state = states.DEAD


func _on_detect_body_entered(body):
	if state != states.DASH:
		player = body
		state = states.CHASE


func _on_detect_body_exited(_body):
	if state != states.DASH:
		state = states.IDLE


func _on_attack_detect_body_entered(_body):
	if not dashing and state != states.DASH:
		
		state = states.ATTACK


func _on_attack_detect_body_exited(_body):
	if attacking and not hit and state != states.DASH:
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.2).timeout
		if state == states.ATTACK:
			attacking = false
			state = states.CHASE
	elif not dashing and state != states.DASH:
		state = states.CHASE


func respawn():
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	position = start_pos
	health = start_health
	await get_tree().create_timer(0.1).timeout
	state = states.IDLE
	player = null


func _on_hitbox_body_entered(body):
	body.hurt(1, position.direction_to(body.position))


func _on_dash_left_body_entered(_body):
	if state != states.DASH:
		dash_direction = "left"
		state = states.DASH


func _on_dash_right_body_entered(_body):
	if state != states.DASH:
		dash_direction = "right"
		state = states.DASH


func _on_dash_up_body_entered(_body):
	if state != states.DASH:
		dash_direction = "up"
		state = states.DASH




func _on_dash_down_body_entered(_body):
	if state != states.DASH:
		dash_direction = "down"
		state = states.DASH
	


func _on_dash_left_body_exited(_body):
	if dashing and state != states.DASH:
		await $AnimationPlayer.animation_finished
		state = states.CHASE
	elif state != states.DASH:
		state = states.CHASE


func _on_stun_timer_timeout():
	var player_position = $"../Player".global_position
	var distance = global_position.distance_to(player_position)
	attacking = false
	if distance <= $AttackDetect/CollisionShape2D.shape.radius * 2.4:
		state = states.ATTACK
	elif distance > $AttackDetect/CollisionShape2D.shape.radius * 2.4 and distance <= $Detect/CollisionShape2D.shape.radius * 2.4:
		state = states.CHASE
	else:
		state = states.IDLE
	stun = false


func _on_dash_hit_body_entered(body):
	body.hurt(1, position.direction_to(body.position))
