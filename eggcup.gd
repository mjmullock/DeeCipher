extends CharacterBody2D

@export var wait_on_proximity: bool = false
@export var direction: int = 1

@onready var sprite = $AnimatedSprite2D
@onready var start_position = global_position

const SPEED = 60.0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var proximity_triggered = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("default")

func _process(delta):
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall():
		direction *= -1
		
	if not proximity_triggered and wait_on_proximity:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED
	
	move_and_slide()

func respawn():
	position = start_position

func _on_proximity_detector_area_entered(area):
	if area.name == "HazardChecker":
		proximity_triggered = true
