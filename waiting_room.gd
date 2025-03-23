extends Node2D

@onready var dee = $Dee

# Called when the node enters the scene tree for the first time.
func _ready():
	dee.set_camera_limits(-600, 80, -110, 500)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
