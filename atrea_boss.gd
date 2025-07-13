extends CharacterBody2D
@export var slash_projectile: PackedScene
@export var scholar_lazer: PackedScene
@export var magic_fire: PackedScene
@export var magic_orb: PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
enum states {IDLE, MELEE_COMBO, JUMP_LIGHTNING, JAB_ATTACK, JUMP_ATTACK, SPELL_CAST, CHASE, DEAD, HURT, DASH, SHOOT, CROUCH_ATTACK}
var state = states.IDLE
var speed = 126
var health = 18
var start_pos
var player
var start_health
var prev_state
var hit
var action_started = false
var actions = ["Attack1", "Attack2", "run_attack1", "run_attack2", "shoot"]
#var weights = [0, 0, 0, 25, 0]
var weights = [30, 0, 15, 25, 30]
var doing_run_attack1 = false
var action_wait = 2
var dead = false
var select_new_action = true
var boss_intro = false
var song_time = false
var invincible = false

func _ready():
	start_pos = position
	start_health = health
	set_physics_process(false)
	#$CollisionShape2D.disabled = true
	#$CanvasLayer/HealthBar.value = health
	player = $"../Player"


func _physics_process(delta):
	$CanvasLayer/HealthBar.value = health
	if player.game_over:
		$BossMusic.stop()
		$CanvasLayer/HealthBar.hide()
		set_physics_process(false)
		$CollisionShape2D.disabled = true
		
	if song_time:
		song_time = false
		await $BossMusic.finished
		$BossMusic.play()
		song_time = true
		
	var player_position = player.global_position
	var distance = global_position.distance_to(player_position)
	if distance <= 200:
		weights[1] = 35
	else:
		weights[1] = 0
	move_and_slide()
	
	if not action_started and not dead:
		pass

func choose_action():
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
		states.SHOOT:
			#Done
			pass
		states.JAB_ATTACK:
			pass
		states.SPELL_CAST:
			pass
		states.JUMP_ATTACK:
			pass
		states.JUMP_LIGHTNING:
			pass
		states.MELEE_COMBO:
			#Done
			pass
		states.CROUCH_ATTACK:
			pass


func shoot_attack():
	velocity = Vector2.ZERO
	for i in range(randi_range(2, 8)):
		if not dead:
			$AnimationPlayer.play("projectile_attack")
			transform.x.x = sign(position.direction_to(player.position).x)
			await get_tree().create_timer(0.7).timeout
			var orb = magic_orb.instantiate()
			get_parent().add_child(orb)
			orb.global_position = global_position
			#$magic_orb.play()
			var base_dir = (player.global_position - orb.global_position).normalized()
			orb.velocity = base_dir * orb.speed
			await get_tree().create_timer(0.3).timeout
	state = states.IDLE
	choose_action()
	
func melee_combo():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Idle")
	await get_tree().create_timer(0.3).timeout
	transform.x.x = sign(position.direction_to(player.position).x)
	$AnimationPlayer.play("Melee_attack_combo")
	await $AnimationPlayer.animation_finished

func jump_lightning():
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.2).timeout
	$AnimationPlayer.play("jump_lightning")
	velocity = position.direction_to(player.position) * speed * 5
	if velocity.x != 0:
		transform.x.x = sign(velocity.x)
	await get_tree().create_timer(1.3).timeout
	velocity = Vector2.ZERO
	await $AnimationPlayer.animation_finished
	pass

func hurt(amount, _dir):
	if not hit:
		hit = true
		if randf() < 0.30:
			$AnimationPlayer.play("block")
		else:
			#$Hit.play()
			$AnimationPlayer.play("hit")
			health -= amount
			#$HitParticle.emitting = true
			await get_tree().create_timer(0.1).timeout
			#$HitParticle.emitting = false
			await get_tree().create_timer(0.2).timeout
			if health <= 0:
				dead = true
				state = states.DEAD
		hit = false

