extends CharacterBody2D
@export var projectile : PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
var speed = 140
enum states {IDLE, CHASE, ATTACK, DEAD, HURT, RUN}
var state = states.IDLE
var player
var attacking = false
var health = 5
var player_pos
var shoot_direction
var start_pos
var start_health

func _ready():
	start_pos = position
	start_health = health
	print("HI")
func _physics_process(delta):
	choose_action()
	move_and_slide()
	
func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			$Death.play()
			$AnimationPlayer.play("Death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("Idle")
			velocity = Vector2.ZERO
		states.CHASE:
			if not attacking:
				$AnimationPlayer.play("Walking")
				velocity = position.direction_to(player.position) * speed
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACK:
			velocity = Vector2.ZERO
			shoot_direction = position.direction_to(player.position)
			transform.x.x = sign(shoot_direction.x)
			if not attacking:
				$AnimationPlayer.play("MoneyBagThrow")
				attacking = true
				await get_tree().create_timer(0.4).timeout
				$Throw.play()
				var Projectile = projectile.instantiate()
				Projectile.start(position, shoot_direction)
				Level1.add_child(Projectile)
				$AttackTimer.start()
		states.RUN:
			if not attacking:
				$AnimationPlayer.play("BackwardsWalking")
				velocity = position.direction_to(player.position) * speed * 0.8 * -1
				if velocity.x != 0:
					transform.x.x = sign(velocity.x) * -1
			#transform.x.x = sign(position.direction_to(player.position).x)
			#hide()
			#await get_tree().create_timer(5).timeout
			#position = player_pos
			#show()
			#$AttackTimer.start()
			#$AnimationPlayer.play("Landing")
			#print("landed")
			#await $AnimationPlayer.animation_finished
			#attacking = false
				
			
	
func hurt(amount, dir):
	$Hit.play()
	health -= amount
	var prev_state = state
	state = states.HURT
	velocity = dir * 100
	$AnimationPlayer.play("Damage")
	await $AnimationPlayer.animation_finished
	state = prev_state
	if health <= 0:
		state = states.DEAD

func _on_detect_body_entered(body):
	player = body
	state = states.CHASE

func _on_detect_body_exited(body):
	state = states.IDLE


func _on_attack_body_entered(body):
		state = states.ATTACK
		
func _on_attack_body_exited(body):
	state = states.CHASE
	
func _on_attack_timer_timeout():
	attacking = false


func _on_walk_away_body_entered(body):
	state = states.RUN


func _on_walk_away_body_exited(body):
	state = states.ATTACK

func respawn():
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	position = start_pos
	health = start_health
	player = null
	await get_tree().create_timer(0.1).timeout
	state = states.IDLE
	
	print("done")
