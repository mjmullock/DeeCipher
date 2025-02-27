extends CharacterBody2D

@export var wait_on_proximity: bool = false
@export var direction: int = 1

@onready var sprite = $AnimatedSprite2D
@onready var start_position = global_position

const SPEED = 60.0;
const ROTATE_SPEED = 70.0;
const FIRE_SPEED = 400.0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var proximity_triggered = false;
var tipsy = false;
var being_fired = false;
var fire_velocity = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	tipsy = Globals.is_enabled(Globals.Mods.TIPSY)
	sprite.play("default")

func _process(delta):
	pass

func _physics_process(delta):
	if being_fired:
		velocity = fire_velocity * FIRE_SPEED * delta
		move_and_slide()
		return
	elif tipsy:
		rotation_degrees += ROTATE_SPEED * delta
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall():
		direction *= -1
		
	if not proximity_triggered and wait_on_proximity:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED
	
	move_and_slide()

func fire(velocity):
	being_fired = true
	fire_velocity = velocity
	collision_layer = 3
	collision_mask = 3

func respawn():
	position = start_position
	being_fired = false

func _on_proximity_detector_area_entered(area):
	if area.name == "HazardChecker":
		proximity_triggered = true
