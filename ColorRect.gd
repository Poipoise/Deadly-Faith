extends TextureRect
signal Cutscene_finished
@export var dialogPath = ""
@export var textSpeed: float = 0.05
var dialog
 
var phraseNum = 0
var finished = false
 
 
func _process(_delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("UI_Interaction") and $/root/World/Final_Cutscene.cutscene_started:
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)
 
func getDialog() -> Array:
	var output= JSON.parse_string(FileAccess.get_file_as_string(dialogPath))
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
 
func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		#queue_free()
		Cutscene_finished.emit()
		return
	
	finished = false
	
	$Name.bbcode_text = dialog[phraseNum]["Name"]
	$Text.bbcode_text = dialog[phraseNum]["Text"]
	
	$Text.visible_characters = 0
	
	var img = "res://Portraits/" + dialog[phraseNum]["Name"] + dialog[phraseNum]["Emotion"] + ".png"
	if ResourceLoader.exists(img):
		$Portrait.texture = load(img)
	else: $Portrait.texture = null
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		await $Timer.timeout
	
	finished = true
	phraseNum += 1
	return

func cutscene_setup(file_path):
	phraseNum = 0
	finished = false
	$Timer.wait_time = textSpeed
	self.dialogPath = file_path
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
