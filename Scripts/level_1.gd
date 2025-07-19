extends Node2D
@export var enemy : PackedScene
@onready var Level1 : Node = get_node("/root/World/Level1")
@export var reward : PackedScene
var summon_position
var summon_amount = 0
var summon_state = false
var counter = 0
var direction
var play = true
var start = false
var gameover = false
var go = true
var chest_opened = false
var chest_position
var done = false
var dummy_hit = false
var tutorial = false
var walked = false
var attacked = false
var run = false
var tutorial_done = false
var dodge_done = false
var tutorial_over = false
signal tutorial_next
signal orb_spawner
func _ready():
	$Cutscene.hide()
	
func _process(_delta):
	$CanvasLayer/StaminaBar.value = $Level1/Player.stamina
	if summon_state:
		summon_state = false
		summon_position.x -= 250
		while counter < summon_amount:
			var enemy_number = randi_range(-120, 120)
			summon_position.y += enemy_number
			var summons = enemy.instantiate()
			Level1.add_child(summons)
			summons.position = summon_position
			summons.summon()
			counter += 1
			
	if play and start and not gameover:
		play = false
		$AudioStreamPlayer.play()
		await $AudioStreamPlayer.finished
		await get_tree().create_timer(0.4).timeout
		if go:
			play = true
	
	if chest_opened:
		var Potion_reward = reward.instantiate()
		add_child(Potion_reward)
		Potion_reward.position.y = chest_position.y + 20
		Potion_reward.position.x = chest_position.x
		chest_opened = false
	
	if tutorial:
		if (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up")) and not walked and $Tutorial_cutscene.first_dialog_done:
			walked = true
			tutorial_next.emit()
		if (Input.is_action_pressed("sprint") and (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up"))) and not run and walked:
			run = true
			tutorial_next.emit()
			
		if dummy_hit and run and not attacked:
			attacked = true
			tutorial_next.emit()
			await get_tree().create_timer(7).timeout
			orb_spawner.emit()
			
		if attacked and not dodge_done and Input.is_action_just_pressed("roll"):
			dodge_done = true
			await get_tree().create_timer(10).timeout
			tutorial_done = true
			tutorial_next.emit()
			
		if tutorial_done and not tutorial_over:
			tutorial_over = true
			await get_tree().create_timer(10).timeout
			tutorial_next.emit()

func _on_death_screen_respawn():
	$Golem_boss_room_collision/CollisionShape2D.set_deferred("disabled", true)
	$Arena_exit_blocker/CollisionShape2D.set_deferred("disabled", true)
	$Arena_exit_blocker/Sprite2D.visible = false
	$Arena_exit_blocker2/CollisionShape2D.set_deferred("disabled", true)
	$Arena_exit_blocker2/Sprite2D.visible = false
	gameover = false
	play = true
	var enemy_nodes = get_tree().get_nodes_in_group("enemy")
	for enemy_ruin in enemy_nodes:
		enemy_ruin.respawn()
	var projectile_nodes = get_tree().get_nodes_in_group("projectile")
	for projectiles in projectile_nodes:
		projectiles.queue_free()
	


func _on_start_screen_start_game():
	#If you want to skip the beginning dialogue uncomment start = true and comment $Cutscene.show() 
	#also turn the cutscene variable in the cutscene script to false/off
	# q$Cutscene.show()
	
	#If you wish to skip tutorial comment tutorial = true in _on_cutscene_finished and turn off cutscene variabble in tutorial cutscene script
	start = true
	$Beginning.play()


func _on_player_game_over():
	gameover = true
	if $Level1/Necromancer != null:
		$Level1/Necromancer.song_time = false
	$AudioStreamPlayer.stop()


func _on_cutscene_finished():
	start = true
	$door.play()
	$Beginning.stop()
	#tutorial = true
	
	
func Boss_Music_Time():
	go = false
	play = false
	$AudioStreamPlayer.stop()



func _on_level_finished_cutscene_starter_start_cutscene(_placeholder, _placeholder2):
	go = false
	play = false
	$AudioStreamPlayer.stop()
	$Final_cutscene_ambience.play()
	for ruin_enemy in get_tree().get_nodes_in_group("ruins_enemy"):
		ruin_enemy.queue_free()

func _on_final_cutscene_finished(_placeholder):
	$Final_cutscene_ambience.stop()
	await get_tree().create_timer(1.3).timeout
	play = true
	go = true


func _on_boundary_collision_body_entered(_body):
	$CanvasLayer/Boundary_message.visible = true


func _on_boundary_collision_body_exited(_body):
	$CanvasLayer/Boundary_message.visible = false


func _on_area_2d_body_entered(body):
	if not done:
		done = true
		$Level1/Player.start_pos = body.position
		
func _on_dummy_dummy_hit():
	dummy_hit = true


func _on_necromancer_died():
	$CanvasLayer/Magic_explanation.visible = true
	await get_tree().create_timer(8).timeout
	$CanvasLayer/Magic_explanation.visible = false



func _on_end_credits_body_entered(body):
	go = false
	play = false
	$AudioStreamPlayer.stop()


func _on_golem_spawning_golem_time():
	$Golem_boss_room_collision/CollisionShape2D.set_deferred("disabled", false)


func _on_golem_boss_golem_dead():
	$CanvasLayer/Heal_potion_explanation.visible = true
	await get_tree().create_timer(15).timeout
	$CanvasLayer/Heal_potion_explanation.visible = false
	
	


func _on_cave_finish_start_cutscene(_placeholder1, _placeholder2):
	go = false
	play = false
	$AudioStreamPlayer.stop()
	$Final_cutscene_ambience.play()
	for cave_enemy in get_tree().get_nodes_in_group("cave_enemy"):
		cave_enemy.queue_free()


func _on_scholar_starter_scholar_time():
	await get_tree().create_timer(0.1).timeout
	$Arena_exit_blocker/CollisionShape2D.set_deferred("disabled", false)
	$Arena_exit_blocker2/CollisionShape2D.set_deferred("disabled", false)
	$Arena_exit_blocker/Sprite2D.visible = true
	$Arena_exit_blocker2/Sprite2D.visible = true


func _on_dark_scholar_scholar_death():
	$Arena_exit_blocker3/CollisionShape2D.set_deferred("disabled", true)
	$Arena_exit_blocker3/Sprite2D.visible = false


func _on_astrea_starter_astrea_time():
	await get_tree().create_timer(0.1).timeout
	$Arena_exit_blocker4/CollisionShape2D.set_deferred("disabled", false)
	$Arena_exit_blocker4/Sprite2D.visible = true
