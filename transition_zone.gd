extends Node2D

@export var next_screen: String = ""
@export var edge: Globals.Edges

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.name != "Dee":
		return
	if next_screen == "":
		print("No screen transition set!!")
		return
	Globals.TransitionPosition = body.position
	Globals.TransitionVelocity = body.velocity
	call_deferred("_transition")

func _transition():
	Globals.TransitionEdge = edge
	get_tree().change_scene_to_file(next_screen)
