extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Dee.set_camera_limits(-250, 50, -300, 650)
	MusicMixer.stop_all()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
