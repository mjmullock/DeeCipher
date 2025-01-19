extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	body.start_force_move()
	Globals.TransitionEdge = Globals.Edges.UNKNOWN
	await FadeAnimator.slow_fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	FadeAnimator.fade_from_black()
