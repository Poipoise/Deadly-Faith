extends CharacterBody2D
@export var projectile : PackedScene
@export var enemy : PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
var speed = 70
enum states {IDLE, FIREAWAY, PROJECTILE, DEAD, HURT, SUMMONER, MOVEAWAY}
var state = states.IDLE
var player
var attacking = false
var health = 10
var start_pos
var start_health
var shoot_direction
var counter = 0
var summon = true
var enemy_number
var direction = 1
var summonable = false
var Fireable = true
var TIMETOATTACK = true
var INAREATOBARRAGE = false
var fireballNumber = 13
var boss_intro = false
func _ready():
	start_pos = position
	start_health = health
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$Sprite2D.hide()
	
func _physics_process(delta):
	choose_action()
	move_and_slide()
	
func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			$AnimationPlayer.play("Death")
			set_physics_process(false)
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("idle")
			velocity = Vector2.ZERO
			if summonable and summon:
				state = states.SUMMONER
			if INAREATOBARRAGE and TIMETOATTACK:
				print(summonable)
				state = states.PROJECTILE
		states.FIREAWAY:
			velocity = position.direction_to(player.position) * speed * -1
			if velocity.x != 0:
				transform.x.x = sign(velocity.x) * -1
			shoot_direction = position.direction_to(player.position)
			transform.x.x = sign(shoot_direction.x)
			if not attacking:
				$AnimationPlayer.play("projectile fire")
				attacking = true
				Fireable = false
				await $AnimationPlayer.animation_finished
				$Fireball.play()
				var Projectile = projectile.instantiate()
				Projectile.start(position, shoot_direction)
				Level1.add_child(Projectile)
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
			shoot_direction = Vector2(-1,0)
			if INAREATOBARRAGE and TIMETOATTACK:
				$AnimationPlayer.play("Projectile Barrage")
				print("FIRED")
				TIMETOATTACK = false
				await $AnimationPlayer.animation_finished
				while counter < fireballNumber:
					var angle = (2*6.28319) / fireballNumber
					#shoot_direction = shoot_direction.from_angle(angle)
					shoot_direction = shoot_direction.rotated(angle)
					print(shoot_direction)
					var Projectile = projectile.instantiate()
					Projectile.start(position, shoot_direction)
					Level1.add_child(Projectile)
					counter += 1
				counter = 0
				$Barrage.start()
				state = states.IDLE
			
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
	$Hit.play()
	health -= amount
	var prev_state = state
	state = states.HURT
	velocity = dir * 100
	$AnimationPlayer.play("hit")
	await $AnimationPlayer.animation_finished
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
	await get_tree().create_timer(0.3).timeout
	state = states.SUMMONER


func _on_barrage_timeout():
	TIMETOATTACK = true


func _on_project_ring_body_entered(body):
	Fireable = false
	INAREATOBARRAGE = true
	state = states.PROJECTILE
	


func _on_project_ring_body_exited(body):
	Fireable = true
	INAREATOBARRAGE = false
	state = states.MOVEAWAY

func respawn():
	state = states.IDLE
	player = null
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$Sprite2D.hide()
	position = start_pos
	health = start_health
	attacking = false
	summon = true
	summonable = false
	Fireable = true
	TIMETOATTACK = true
	INAREATOBARRAGE = false
	boss_intro = false
	


func _on_boss_spawning_boss_time():
	if not boss_intro:
		boss_intro = true
		$CanvasLayer/Label.show()
		$Sprite2D.show()
		var player_vars = get_node("/root/World/Level1/Player")
		player_vars.boss_position = global_position
		$AnimationPlayer.play("Spawning")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("idle")
		await get_tree().create_timer(3.8).timeout
		$CanvasLayer/Label.hide()
		set_physics_process(true)
		$CollisionShape2D.disabled = false
	
