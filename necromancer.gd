extends CharacterBody2D
@export var projectile : PackedScene
@export var enemy : PackedScene
var speed = 70
enum states {IDLE, FIREAWAY, PROJECTILE, DEAD, HURT, SUMMONER, MOVEAWAY}
var state = states.IDLE
var player
var attacking = false
var health = 3
var start_pos
var start_health
var shoot_direction
var counter = 0
var summon = true
var enemy_number
var direction = 1
var summonable = false
var Fireable = true
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
		states.IDLE:
			$AnimationPlayer.play("idle")
			velocity = Vector2.ZERO
			if summonable and summon:
				state = states.SUMMONER
		states.FIREAWAY:
			velocity = position.direction_to(player.position) * speed * -1
			if velocity.x != 0:
				transform.x.x = sign(velocity.x) * -1
			shoot_direction = position.direction_to(player.position)
			transform.x.x = sign(shoot_direction.x)
			if not attacking:
				$AnimationPlayer.play("projectile fire")
				print("played")
				attacking = true
				Fireable = false
				await $AnimationPlayer.animation_finished
				var Projectile = projectile.instantiate()
				Projectile.start(position, shoot_direction)
				get_tree().root.add_child(Projectile)
				$Fireball.play()
				$AttackTimer.start()
				state = states.MOVEAWAY
				
		states.MOVEAWAY:
			$AnimationPlayer.play("move")
			velocity = position.direction_to(player.position) * speed * -1
			if velocity.x != 0:
				transform.x.x = sign(velocity.x) * -1
			if not attacking and Fireable:
				state = states.FIREAWAY
			
		states.PROJECTILE:
			velocity = Vector2.ZERO
			
		states.SUMMONER:
			velocity = Vector2.ZERO
			if summon:
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Summoning")
				summon = false
				await get_tree().create_timer(1.3).timeout
				var enemy_number = randf_range(1, 3)
				var world_vars = get_node("/root/World")
				world_vars.summon_state = true
				world_vars.summon_position = position
				world_vars.summon_amount = enemy_number
				world_vars.counter = 0
				$SummonTimer.start()
				await $AnimationPlayer.animation_finished
				state = states.IDLE
func hurt(amount, dir):
	health -= amount
	var prev_state = state
	state = states.HURT
	velocity = dir * 100
	await get_tree().create_timer(0.2).timeout
	state = prev_state
	if health <= 0:
		state = states.DEAD


func _on_summon_timer_timeout():
	summon = true



func _on_summon_body_entered(body):
	summonable = true
	player = body
	state = states.SUMMONER



func _on_summon_body_exited(body):
	summonable = false
	state = states.IDLE



func _on_attack_timer_timeout():
	attacking = false
	Fireable = true


func _on_away_body_entered(body):
	summonable = false
	player = body
	Fireable = true
	state = states.MOVEAWAY
	



func _on_away_body_exited(body):
	Fireable = false
	summonable = true
	state = states.SUMMONER