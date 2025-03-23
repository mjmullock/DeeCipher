extends CenterContainer

@onready var start_button = $VBoxContainer/StartButton
@onready var gem_display = $VBoxContainer/GemDisplay
@onready var subtitle = $VBoxContainer/Subtitle

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicMixer.play_title()
	_wipe_level_state()
	start_button.grab_focus()
	
	if Globals.ActiveMods.is_empty():
		subtitle.text = "A puzzle platformer"
	else:
		subtitle.text = "A puzzling platformer"
	
	var gem: TextureRect
	for gem_id in Globals.CollectedGems:
		gem = TextureRect.new()
		
		var image = Image.load_from_file("res://gem.png")
		var texture = ImageTexture.create_from_image(image)
		gem.texture = texture
		gem_display.add_child(gem)
		print(gem_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Reset all state that tracks things within the game levels.
# So things like "coins collected", but not e.g. "active mods".
func _wipe_level_state():
	Globals.TransitionEdge = Globals.Edges.UNKNOWN
	Globals.TransitionVelocity = Vector2(0, 0)
	Globals.CollectedCoins = {}
	Globals.Points = 0
	Globals.Permajump = false
	Globals.HasSilverKey = false


func _on_start_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://screen_one.tscn")
	FadeAnimator.fade_from_black()
	if Globals.is_enabled(Globals.Mods.KAIZO):
		MusicMixer.play_kaizo()
	else:
		MusicMixer.play_level()


func _on_mods_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://mod_page.tscn")
	FadeAnimator.fade_from_black()


func _on_settings_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://settings_page.tscn")
	FadeAnimator.fade_from_black()


func _on_about_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://about_page_one.tscn")
	FadeAnimator.fade_from_black()
