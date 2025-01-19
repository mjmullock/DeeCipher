extends Control

@onready var resume_button = $MarginContainer/VBoxContainer/ResumeButton

# Called when the node enters the scene tree for the first time.
func _ready():
	resume_button.grab_focus()
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_button_pressed():
	get_tree().paused = false
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	FadeAnimator.fade_from_black()


func _on_resume_button_pressed():
	get_tree().paused = false
	Events.unpause_game.emit()
	queue_free()
