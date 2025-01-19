extends Node2D

@export var uuid: String

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.CollectedGems.has(uuid):
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	# MusicMixer.play("gem_jingle")
	Globals.CollectedGems[uuid] = null
	queue_free()
