extends Node2D

@export var points: int = 100
@export var uuid: String
@export var has_tipsy_behavior: bool = false

@onready var sprite = $AnimatedSprite2D

const ROTATE_SPEED = 90.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.CollectedCoins.has(uuid):
		queue_free()
	sprite.play("default")
	if Globals.is_enabled(Globals.Mods.TIPSY) and has_tipsy_behavior:
		rotation_degrees = 100.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if Globals.is_enabled(Globals.Mods.TIPSY) and has_tipsy_behavior:
		rotation_degrees += ROTATE_SPEED * delta
		return

func _on_coin_collect_zone_body_entered(body):
	SfxMixer.play_coin()
	Globals.add_points(points)
	Globals.CollectedCoins[uuid] = null
	Events.points_acquired.emit()
	queue_free()
