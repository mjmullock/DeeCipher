extends Control

@export var prev_page: String
@export var next_page: String

@onready var prev_button = $CenterContainer/VBoxContainer/HBoxContainer/PrevButton
@onready var next_button = $CenterContainer/VBoxContainer/HBoxContainer/NextButton
@onready var menu_button = $CenterContainer/VBoxContainer/HBoxContainer/MenuButton

# Called when the node enters the scene tree for the first time.
func _ready():
	if next_page == "":
		next_button.disabled = true
		menu_button.grab_focus()
	elif prev_page == "":
		prev_button.disabled = true
		next_button.grab_focus()
	else:
		next_button.grab_focus()


func _on_menu_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	FadeAnimator.fade_from_black()


func _on_next_button_pressed():
	get_tree().change_scene_to_file(next_page)


func _on_prev_button_pressed():
	get_tree().change_scene_to_file(prev_page)


func _on_guide_button_pressed():
	OS.shell_open("https://github.com/mjmullock/DeeCipher/blob/main/spoiler_test.md")
