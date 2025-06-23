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
signal tutorial_next
func _ready():
	$Cutscene.hide()
	
func _process(delta):
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
		if (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up")) and not walked:
			print("WASD TRIGGER")
			walked = true
			tutorial_next.emit()
		if (Input.is_action_pressed("sprint") and (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up"))) and not run and walked:
			run = true
			tutorial_next.emit()
			
		if dummy_hit and run and not attacked:
			print("DUMMY HIT TRIGGER")
			attacked = true
			tutorial_next.emit()
		if attacked and not tutorial_done:
			tutorial_done = true
			print("DODGE TRIGGER")
			await get_tree().create_timer(30).timeout
			tutorial_next.emit()

func _on_death_screen_respawn():
	gameover = false
	play = true
	var enemy_nodes = get_tree().get_nodes_in_group("enemy")
	for enemy in enemy_nodes:
		enemy.respawn()
	var projectile_nodes = get_tree().get_nodes_in_group("projectile")
	for projectiles in projectile_nodes:
		projectiles.destroy()
	


func _on_start_screen_start_game():
	#If you want to skip the beginning dialogue uncomment start = true and comment $Cutscene.show() 
	#also turn the cutscene variable in the cutscene script to false/off
	# q$Cutscene.show()
	
	#If you wish to skip tutorial comment tutorial = true in _on_cutscene_finished and turn off cutscene variabble in tutorial cutscene script
	start = true
	$Beginning.play()


func _on_player_game_over():
	gameover = true
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



func _on_level_finished_cutscene_starter_start_cutscene(placeholder, placeholder2):
	go = false
	play = false
	$AudioStreamPlayer.stop()
	$Final_cutscene_ambience.play()


func _on_final_cutscene_finished(placeholder):
	$Final_cutscene_ambience.stop()
	await get_tree().create_timer(1.3).timeout
	play = true
	go = true


func _on_boundary_collision_body_entered(body):
	$CanvasLayer/Boundary_message.visible = true


func _on_boundary_collision_body_exited(body):
	$CanvasLayer/Boundary_message.visible = false


func _on_area_2d_body_entered(body):
	if not done:
		done = true
		$Level1/Player.start_pos = body.position
		
func _on_dummy_dummy_hit():
	dummy_hit = true
	print("DUMMY HIT")
