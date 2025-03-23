class_name Eggcup
extends CharacterBody2D

@export var wait_on_proximity: bool = false
@export var suspended: bool = false
@export var direction: int = 1
@export var semaphore_angle: Vector2
@export var semaphore_pair: Eggcup

@onready var sprite = $AnimatedSprite2D
@onready var start_position = global_position
@onready var semaphore_timer = $SemaphoreTimer

const SPEED = 60.0;
const ROTATE_SPEED = 70.0;
const FIRE_SPEED = 400.0;
const SEMAPHORE_SPEED = 80.0;
const SEMAPHORE_SIZE = 50.0;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var proximity_triggered = false
var tipsy = false
var just_fired = false
var being_fired = false
var semaphore_state = false
var semaphore_start = Vector2(0, 0)
var semaphore_end = Vector2(0, 0)
var semaphore_outgoing = true
var fire_velocity = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	tipsy = Globals.is_enabled(Globals.Mods.TIPSY)
	if tipsy and not suspended:
		start_position.y -= 32
		global_position = start_position
	sprite.play("default")

func _process(delta):
	pass

func _physics_process(delta):
	if suspended:
		return
		
	if semaphore_state:
		if semaphore_outgoing:
			position += semaphore_angle * SEMAPHORE_SPEED * delta
		else:
			position -= semaphore_angle * SEMAPHORE_SPEED * delta
		return
	if just_fired:
		velocity = fire_velocity * FIRE_SPEED * delta
		being_fired = true
		just_fired = false
	if being_fired:
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
	print("firing?")
	if suspended:
		# wipe all collision
		collision_layer = 0
		collision_layer = 0
	else:
		# should still hit each other
		collision_layer = 3
		collision_mask = 3
	suspended = false
	just_fired = true
	fire_velocity = velocity

func respawn():
	position = start_position
	being_fired = false
	semaphore_state = false

func _on_proximity_detector_area_entered(area):
	if area.name == "HazardChecker":
		proximity_triggered = true


func begin_semaphore():
	print("semaphore?")
	collision_layer = 0
	collision_mask = 0
	semaphore_state = true
	semaphore_start = position
	semaphore_end = position + SEMAPHORE_SIZE * semaphore_angle
	velocity = Vector2(0, 0)
	semaphore_timer.start()
	Globals.HasCollidedTipsies = true


func _on_semaphore_detector_body_entered(body):
	if not being_fired:
		return
	if semaphore_state:
		return
	if body == semaphore_pair:
		begin_semaphore()
		body.begin_semaphore()


func _on_semaphore_timer_timeout():
	semaphore_outgoing = !semaphore_outgoing
