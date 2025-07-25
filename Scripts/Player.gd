extends CharacterBody2D

signal health_changed
signal Game_Over
@export var invincible = false
@export var roll_speed = 250
@export var projectile : PackedScene
@export var magic_ability = false
@onready var Level1 : Node = get_node("/root/World/Level1")

var run_speed = 135
var sprint_speed = 250
var attacking = false
var health = 5
#var health = 10
enum states {IDLE, MOVING, ATTACKING, DEAD, HURT, ROLLING, FIREBALL}
var state = states.IDLE
var input
var rolling = false
var stamina = 160:
	set = set_stamina
var stamina_empty = true
var recharging = false
var stamina_depletion = .5
var attack_number = 0
var gamestart = false
var start_pos
var start_health
var player_hurt = false
var game_over = false
var boss_position
var boss_spawing_done = false
var movement_allowed = true
var fireball = false
var potion_timer = false
var time_passed = 0
var Duration = 90.0
var potion = false
#var potion = true
var cutscene = false

func _ready():
	start_pos = position
	start_health = health
	health_changed.emit(health)
	$CanvasLayer/healing_bar.value = $CanvasLayer/healing_bar.max_value
	
func _physics_process(delta):
	if recharging:
		if stamina < 160:
			stamina = stamina + stamina_depletion
		else:
			recharging = false
	
	if gamestart and movement_allowed:
		if not player_hurt:
			choose_action()
		if stamina == 0 && stamina_empty:
			stamina_check()
		input = Input.get_vector("left", "right", "up", "down")
	
		
		if potion_timer and potion:
			time_passed += delta
			$CanvasLayer/healing_bar.value = (time_passed / Duration) * $CanvasLayer/healing_bar.max_value
			$CanvasLayer/timer_label.visible = true
			$CanvasLayer/timer_label.text = str(round((Duration - time_passed)))
			if $CanvasLayer/healing_bar.value == $CanvasLayer/healing_bar.max_value:
				$CanvasLayer/timer_label.visible = false
				time_passed = 0
				potion_timer = false

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
	if gamestart and movement_allowed:
		if event.is_action_pressed("attack") && not attacking && stamina >= 10:
			if not game_over:
				$swing.play()
			state = states.ATTACKING
			recharging = false
			attack_number += 1
			stamina = stamina - 10
		if event.is_action_pressed("roll") && stamina >= 25 && not rolling:
			rolling = false
			recharging = false
			state = states.ROLLING
			stamina = stamina - 25
		if event.is_action("Fireball") and stamina >= 35 and not attacking and magic_ability:
			state = states.FIREBALL
			var mouse_pos = get_global_mouse_position()
			var shoot_direction = (mouse_pos - global_position).normalized()
			var Projectile = projectile.instantiate()
			Projectile.start(position, shoot_direction)
			Level1.add_child(Projectile)
			recharging = false
			stamina = stamina - 35
		if event.is_action("heal") and $CanvasLayer/healing_bar.value == $CanvasLayer/healing_bar.max_value and potion:
			$CanvasLayer/healing_bar.value = 0
			health = start_health
			health_changed.emit(health)
			stamina = 150
			potion_timer = true
			
		
func choose_action():
	match state:
		states.DEAD:
			$RunParticles.emitting = false
			$AnimationPlayer.play("death")
			set_physics_process(false)
			velocity = Vector2.ZERO
			$CollisionShape2D.disabled = true
			await $AnimationPlayer.animation_finished
			$CanvasLayer.visible = false
			Game_Over.emit()
			game_over = true
		states.IDLE:
			$RunParticles.emitting = false
			$AnimationPlayer.play("Idle")
			
		states.MOVING:
			$RunParticles.emitting = true
			$AnimationPlayer.play("run")
			if velocity.x != 0:
				transform.x.x = sign(velocity.x) 
		states.ATTACKING:
			$RunParticles.emitting = false
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
			$RunParticles.emitting = false
			rolling = true
			$AnimationPlayer.play("Roll")
			await $AnimationPlayer.animation_finished
			rolling = false
			if velocity.length() > 0:
				state = states.MOVING
			if velocity.length() == 0:
				state = states.IDLE
		states.FIREBALL:
			$RunParticles.emitting = false
			attacking = true
			$AnimationPlayer.play("Fireball")
			await $AnimationPlayer.animation_finished
			attacking = false
			if velocity.length() > 0:
				state = states.MOVING
			if velocity.length() == 0:
				state = states.IDLE
			
func die():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("death")

func hurt(amount, dir):
	if not invincible and not cutscene:
		$Hit.play()
		var prev_state = state
		player_hurt = true
		state = states.HURT
		health -= amount
		health_changed.emit(health)
		velocity = dir * 100
		$AnimationPlayer.play("hurt")
		await $AnimationPlayer.animation_finished
		player_hurt = false
		state = prev_state
		if health <= 0:
			$CanvasLayer/Label.visible = false
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
	recharging = true

func _on_stamina_cooldown_timeout():
	recharging = true


func _on_hurtbox_body_entered(body):
	body.hurt(1, position.direction_to(body.position))


func _on_start_screen_start_game():
	gamestart = true


func _on_death_screen_respawn():
	position = start_pos
	health = start_health
	health_changed.emit(health)
	stamina = 150
	state = states.IDLE
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	game_over = false
	boss_spawing_done = false
	if potion:
		$CanvasLayer/healing_bar.visible = true
		$CanvasLayer/healing_bar.value = $CanvasLayer/healing_bar.max_value
		$CanvasLayer/timer_label.visible = false
		time_passed = 0
		potion_timer = false


func _on_sound_timer_timeout():
	$CanvasLayer/Label.visible = false


func _on_camp_fire_set_spawn():
	start_pos = position
	health = start_health
	health_changed.emit(health)
	$CanvasLayer/healing_bar.value = $CanvasLayer/healing_bar.max_value
	$CanvasLayer/timer_label.visible = false
	time_passed = 0
	potion_timer = false


func _on_boss_spawning_boss_time():
	if not boss_spawing_done:
		cutscene = true
		boss_spawing_done = true
		set_physics_process(false)
		await get_tree().create_timer(0.1).timeout 
		boss_position = boss_position - global_position
		$Camera2D.offset = boss_position
		await get_tree().create_timer(5).timeout
		set_physics_process(true)
		$Camera2D.offset.x = 0
		$Camera2D.offset.y = 0
		cutscene = false

func health_change():
	health_changed.emit(health)
	
	
func _on_level_finished_cutscene_starter_start_cutscene(_placeholder, _placeholder2):
	cutscene = true
	movement_allowed = false
	$AnimationPlayer.play("Idle")


func _on_Ruins_finished(location):
	cutscene = false
	movement_allowed = true
	position = location
	_on_camp_fire_set_spawn()
	


func _on_necromancer_died():
	magic_ability = true


func _on_tutorial_cutscene_finished():
	position = Vector2(1088, -62)


func _on_golem_boss_golem_dead():
	health = 10
	start_health = health
	health_changed.emit(health)
	potion = true
	$CanvasLayer/healing_bar.visible = true


func _on_astrea_starter_astrea_time():
	start_pos = Vector2(4987, 1130)
	health = 10
	health_changed.emit(health)
	$CanvasLayer/healing_bar.value = $CanvasLayer/healing_bar.max_value
	$CanvasLayer/timer_label.visible = false
	time_passed = 0
	potion_timer = false

func Asrea_phase_change():
	cutscene = true
	set_physics_process(false)
	position = Vector2(4987, 1130)
	await get_tree().create_timer(0.1).timeout 
	boss_position = boss_position - global_position
	$Camera2D.offset = boss_position
	await get_tree().create_timer(5.7).timeout
	set_physics_process(true)
	$Camera2D.offset.x = 0
	$Camera2D.offset.y = 0
	cutscene = false
	$CanvasLayer/Label.visible = true
	$LabelTimer.start()
	


func Astrea_cutscene():
	movement_allowed = false
	$AnimationPlayer.play("Idle")


func _on_betrayal_cutscene_finished():
	movement_allowed = true


func _on_atrea_boss_ending():
	cutscene = true
	movement_allowed = false
	$AnimationPlayer.play("Idle")
