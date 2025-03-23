extends CenterContainer

@onready var first_setting = $VBoxContainer/CheckButton
@onready var music = $VBoxContainer/CheckButton
@onready var sfx = $VBoxContainer/CheckButton2
@onready var delay = $VBoxContainer/HBoxContainer/SpinBox

# Called when the node enters the scene tree for the first time.
func _ready():
	first_setting.grab_focus()
	music.button_pressed = Globals.play_music
	sfx.button_pressed = Globals.play_sfx
	delay.value = Globals.trans_delay


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	FadeAnimator.fade_from_black()


func _on_check_button_toggled(toggled_on):
	Globals.set_play_music(toggled_on)


func _on_check_button_2_toggled(toggled_on):
	Globals.set_play_sfx(toggled_on)


func _on_spin_box_value_changed(value):
	Globals.trans_delay = value
