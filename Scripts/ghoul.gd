extends CharacterBody2D

var speed = 135
enum states {IDLE, CHASE, ATTACK, DEAD, HURT,SUMMONING}
var state = states.IDLE
var player
var attacking = false
var health = 3
var start_pos
var start_health
var death_scene
var summoned = false
var prev_state
var hit
func _ready():
	start_pos = position
	start_health = health
	
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
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(3).timeout
			$AnimationPlayer.play("disapear")
		states.IDLE:
			$AnimationPlayer.play("idle")
			velocity = Vector2.ZERO
		states.CHASE:
			$AnimationPlayer.play("run")
			velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACK:
			if not attacking:
				$Growl.play()
				velocity = Vector2.ZERO
				attacking = true
				$AnimationPlayer.play("attack")
				transform.x.x = sign(position.direction_to(player.position).x)
				await get_tree().create_timer(1.1).timeout
				attacking = false
	
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
		#$AnimationPlayer.play("damaged")
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
	player = body
	state = states.CHASE

func _on_detect_body_exited(body):
	state = states.IDLE

func _on_attack_body_entered(body):
	prev_state = states.ATTACK
	state = states.ATTACK

func _on_attack_body_exited(body):
	prev_state = states.CHASE
	if attacking and not hit:
		await $AnimationPlayer.animation_finished
		state = states.CHASE



func _on_ghoul_hurt_box_body_entered(body):
	print("attacked")
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
	$Detect/CollisionShape2D.disabled = true
	$Attack/CollisionShape2D.disabled = true
	state = states.SUMMONING
	summoned = true
	state = states.SUMMONING
	$AnimationPlayer.play("revive")
	await $AnimationPlayer.animation_finished
	state = states.IDLE 
	$CollisionShape2D.disabled = false
	$Detect/CollisionShape2D.disabled = false
	$Attack/CollisionShape2D.disabled = false


