extends StaticBody2D

@export var camera_scroll: Vector2

var grabbed_camera: Camera2D
var old_position: Vector2
var old_smoothing_speed: float

func _ready():
	if not Globals.is_enabled(Globals.Mods.BLOOM):
		queue_free()

func _on_area_2d_body_entered(body):
	grabbed_camera = body.camera
	old_position = grabbed_camera.position
	old_smoothing_speed = grabbed_camera.position_smoothing_speed
	
	grabbed_camera.position_smoothing_speed = 1
	grabbed_camera.position += camera_scroll
	

func _on_area_2d_body_exited(body):
	grabbed_camera.position_smoothing_speed = old_smoothing_speed
	grabbed_camera.position = old_position
