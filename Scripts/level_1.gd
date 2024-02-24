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
	$Cutscene.show()
	#start = true
	$Beginning.play()


func _on_player_game_over():
	gameover = true
	$Level1/Necromancer.song_time = false
	$AudioStreamPlayer.stop()


func _on_cutscene_finished():
	start = true
	$door.play()
	$Beginning.stop()
	
	
func Boss_Music_Time():
	go = false
	play = false
	$AudioStreamPlayer.stop()



func _on_level_finished_cutscene_starter_start_cutscene():
	go = false
	play = false
	$AudioStreamPlayer.stop()
	$Final_cutscene_ambience.play()


func _on_final_cutscene_finished():
	$Final_cutscene_ambience.stop()
