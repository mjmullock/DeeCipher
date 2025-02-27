extends Node2D

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.is_enabled(Globals.Mods.ARGENT):
		queue_free()
	sprite.play("default")

func _on_area_2d_body_entered(body):
	Globals.HasSilverKey = true
	queue_free()
