extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Dee.set_camera_limits(-350, 200, -400, 400)
	MusicMixer.play_title()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
