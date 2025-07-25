extends CharacterBody2D

var speed = 135
enum states {IDLE, CHASE, ATTACK, DEAD, HURT,SUMMONING}
var state = states.IDLE
var player
var attacking = false
var health = 4
var start_pos
var start_health
var summoned = false
var prev_state
var hit
func _ready():
	start_pos = position
	start_health = health
	
func _physics_process(_delta):
	choose_action()
	move_and_slide()
	
func choose_action():
	match state:
		states.DEAD:
			$AnimationPlayer.play("death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
			await $AnimationPlayer.animation_finished
			$Sprite2D.hide()
		states.IDLE:
			$AnimationPlayer.play("Idle")
			velocity = Vector2.ZERO
		states.CHASE:
			$AnimationPlayer.play("Idle")
			velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
			var player_pos = player.global_position
			var distance = global_position.distance_to(player_pos)
			if distance < 170:
				state = states.ATTACK
		states.ATTACK:
			if not attacking:
				attacking = true
				velocity = Vector2.ZERO
				await get_tree().create_timer(0.5).timeout
				velocity = position.direction_to(player.position) * speed * 2.5
				$AnimationPlayer.play("bite")
				await $AnimationPlayer.animation_finished
				$AnimationPlayer.play("Idle")
				velocity = Vector2.ZERO
				await get_tree().create_timer(0.8).timeout
				attacking = false
				state = states.CHASE
			
	
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


func _on_detect_area_body_entered(body):
	player = body
	state = states.CHASE


func _on_detect_area_body_exited(body):
	state= states.IDLE


func _on_area_2d_body_entered(body):
	body.hurt(1, position.direction_to(body.position))

func respawn():
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	position = start_pos
	health = start_health
	await get_tree().create_timer(0.1).timeout
	state = states.IDLE
	player = null
	if summoned:
		queue_free()

func summon():
	$CollisionShape2D.disabled = true
	$DetectArea/CollisionShape2D.disabled = true
	state = states.SUMMONING
	summoned = true
	state = states.SUMMONING
	$AnimationPlayer.play("revive")
	await $AnimationPlayer.animation_finished
	state = states.IDLE 
	$CollisionShape2D.disabled = false
	$DetectArea/CollisionShape2D.disabled = false
