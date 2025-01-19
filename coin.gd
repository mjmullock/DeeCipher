extends Node2D

@export var points: int = 100
@export var uuid: String

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.CollectedCoins.has(uuid):
		queue_free()
	sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_coin_collect_zone_body_entered(body):
	Globals.add_points(points)
	Globals.CollectedCoins[uuid] = null
	Events.points_acquired.emit()
	queue_free()
