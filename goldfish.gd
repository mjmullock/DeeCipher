extends Node2D

@export var swim_radius: int = 60
@export var direction: int = -1
@export var initial_offset: int = 0

const SPEED = 30

var root_position: Vector2

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	root_position = position
	sprite.flip_h = (direction > 0)
	sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (_too_far_from_root()):
		_turn_around()
	
	position.x += direction * SPEED * delta
	
func _too_far_from_root():
	if direction == 1:
		return position.x > root_position.x + swim_radius
	return position.x < root_position.x - swim_radius

func _turn_around():
	direction *= -1
	sprite.flip_h = (direction > 0)
