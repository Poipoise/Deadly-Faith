extends TextureRect
signal Cutscene_finished
@export var dialogPath = ""
@export var textSpeed: float = 0.05
var dialog
 
var phraseNum = 0
var finished = false
 
func _ready():
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
 
func _process(_delta):
	$Indicator.visible = finished
	#print($/root/World/Tutorial_cutscene.cutscene_next)
	if $/root/World/Tutorial_cutscene.cutscene_next:
		if finished :
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
		queue_free()
		Cutscene_finished.emit()
		return
	
	finished = false
	$/root/World/Tutorial_cutscene.cutscene_next = false
	$Name.bbcode_text = dialog[phraseNum]["Name"]
	$Text.bbcode_text = dialog[phraseNum]["Text"]
	
	$Text.visible_characters = 0
	
	var img = "res://Portraits/" + dialog[phraseNum]["Name"] + dialog[phraseNum]["Emotion"] + ".png"
	if FileAccess.file_exists(img):
		$Portrait.texture = load(img)
	else: $Portrait.texture = null
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		await $Timer.timeout
	await get_tree().create_timer(10.0).timeout
	finished = true
	phraseNum += 1
	return
