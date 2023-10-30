extends CharacterBody2D
var CanAttack = true
var speed = 135
enum states {IDLE, CHASE, ATTACK, DEAD, HURT}
var state = states.IDLE
var player
var attacking = false
var health = 3
var player_pos
func _physics_process(delta):
	choose_action()
	move_and_slide()
	
func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			$AnimationPlayer.play("death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("Idle")
			velocity = Vector2.ZERO
		states.CHASE:
			$AnimationPlayer.play("Walking")
			velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACK:
			velocity = Vector2.ZERO
			attacking = true
			$AnimationPlayer.play("Jump")
			transform.x.x = sign(position.direction_to(player.position).x)
			await $AnimationPlayer.animation_finished
			hide()
			await get_tree().create_timer(5).timeout
			position = player_pos
			show()
			$AttackTimer.start()
			$AnimationPlayer.play("Landing")
			print("landed")
			await $AnimationPlayer.animation_finished
			attacking = false
				
			
	
func hurt(amount, dir):
	health -= amount
	var prev_state = state
	state = states.HURT
	velocity = dir * 100
	await get_tree().create_timer(0.2).timeout
	state = prev_state
	if health <= 0:
		state = states.DEAD

func _on_detect_body_entered(body):
	player = body
	state = states.CHASE

func _on_detect_body_exited(body):
	state = states.IDLE


func _on_attack_body_entered(body):
	if CanAttack:
		state = states.ATTACK
		player_pos = player.position
		CanAttack = false
func _on_attack_body_exited(body):
	if not attacking:
		state = states.CHASE



func _on_attack_timer_timeout():
	CanAttack = true
