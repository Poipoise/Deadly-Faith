extends CanvasLayer

const section_time := 2.0
const line_time := 0.3
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color.YELLOW

# var scroll_speed := base_speed
var speed_up := false

@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"Deadly Faith"
	],[
		"Programming",
		"Anthony Melgar",
		"Andrew Palchevskiy"
	],[
		"Art",
		"Anokolisa",
		"Cainos",
		"CreativeKind",
		"Elthen",
		"Namatnieks",
		"PixiVan",
	],[
		"Music",
		"AlkaKrab",
		"Christopher Larkin",
		"Toby Fox",
		"Yuka Kitamura",
		"xDeviruchi"
	],[
		"Sound Effects",
		"Retrieved from Pixabay"
	],[
		"Testers",
		"Who needs them"
	],[
		"Tools used",
		"Stable Diffusion",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Some art created with Piskel",
		"https://www.piskelapp.com/"
	],[
		"Special thanks",
		"People who provide free assets",
		"My friends",
		"YOU"
	]
]
var Activate = false
var song_time = false

func _ready():
	$/root/World/GodotCredits.visible = false
	pass
	
func _process(delta):
	if Activate:
		$/root/World/GodotCredits.visible = true
		if song_time:
			song_time = false
			await $AudioStreamPlayer.finished
			$AudioStreamPlayer.play()
			song_time = true
			
		var scroll_speed = base_speed * delta
	
		if section_next:
			section_timer += delta * speed_up_multiplier if speed_up else delta
			if section_timer >= section_time:
				section_timer -= section_time
			
				if credits.size() > 0:
					started = true
					section = credits.pop_front()
					curr_line = 0
					add_line()
	
		else:
			line_timer += delta * speed_up_multiplier if speed_up else delta
			if line_timer >= line_time:
				line_timer -= line_time
				add_line()
	
		if speed_up:
			scroll_speed *= speed_up_multiplier
	
		if lines.size() > 0:
			for l in lines:
				l.position.y -= scroll_speed
				if l.position.y < -l.get_line_height():
					lines.erase(l)
					l.queue_free()
		elif started:
			finish()


func finish():
	if not finished:
		finished = true
		# This is called when the credits finish and returns to the main menu
		$AnimationPlayer.play("Thank_You_fade_in")
		#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		# new_line.add_color_override("font_color", title_color)
		new_line.set("theme_override_colors/font_color", title_color)
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


#func _unhandled_input(event):
	#if event.is_action_pressed("ui_cancel"):
		#finish()
	#if event.is_action_pressed("ui_down") and !event.is_echo():
		#speed_up = true
	#if event.is_action_released("ui_down") and !event.is_echo():
		#speed_up = false


func _on_end_credits_done():
	Activate = true
	song_time = true
	$AudioStreamPlayer.play()
