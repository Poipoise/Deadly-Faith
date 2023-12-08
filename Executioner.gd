extends CharacterBody2D

var speed = 150
enum states {IDLE, TELEPORT, ATTACK, DEAD, HURT,}
var state = states.IDLE
var player
var attacking = false
var health = 3
var start_pos
var start_health
var death_scene
var summoned = false
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
		states.TELEPORT:
			$AnimationPlayer.play("teleport")
			velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACK:
			velocity = Vector2.ZERO
			attacking = true
			$AnimationPlayer.play("attack")
			transform.x.x = sign(position.direction_to(player.position).x)
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



func _on_ghoul_hurt_box_body_entered(body):
	print("attacked")
	body.hurt(1, position.direction_to(body.position))


func respawn():
	position = start_pos
	health = start_health
	state = states.IDLE
	if summoned:
		queue_free()


func _on_chase_body_entered(body):
	player = body
	state = states.TELEPORT


func _on_chase_body_exited(body):
	state = states.IDLE


func _on_attack_box_body_entered(body):
	state = states.ATTACK
	
func _on_attack_box_body_exited(body):
	if attacking:
		await $AnimationPlayer.animation_finished
	state = states.TELEPORT

