extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var start_position = global_position

const SPEED = 150.0
const JUMP_VELOCITY = -320.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var locked = false
var locked_x_velocity = 0.0
var glowing = false
var being_pushed = false
var pusher: CharacterBody2D
var can_double_jump = Globals.is_enabled(Globals.Mods.JUMPY)
var has_double_jump = false


func _ready():
	if Globals.Permajump:
		_glow()
		has_double_jump = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_pause"):
		if can_double_jump:
			Globals.Permajump = has_double_jump
		Events.pause_game.emit()
	
func _physics_process(delta):
	
	if being_pushed and is_on_wall():
		_execute_noclip(delta)
	
	var current_velocity = velocity
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		if glowing and not Globals.Permajump:
			_unglow()
		has_double_jump = true
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
			if can_double_jump:
				_glow()
	elif can_double_jump and has_double_jump:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
			if not Globals.Permajump:
				has_double_jump = false
				_unglow()
		elif Input.is_action_just_released("ui_up") and velocity.y < JUMP_VELOCITY / 3:
			# "short hop" - prematurely reduce upward velocity
			velocity.y = JUMP_VELOCITY / 3
	else:	
		if Input.is_action_just_released("ui_up") and velocity.y < JUMP_VELOCITY / 3:
			# "short hop" - prematurely reduce upward velocity
			velocity.y = JUMP_VELOCITY / 3


	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if locked:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.speed_scale = 0.5
		velocity.x = locked_x_velocity
		velocity.y = current_velocity.y + gravity * delta
		move_and_slide()
	else:
		if being_pushed:
			velocity += pusher.velocity
		update_animation(direction)
		move_and_slide()

func update_animation(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	elif input_axis != 0:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
	
func _on_hazard_checker_area_entered(area):
	print("Area in hazard checker!")
	print(area.name)
	if area.name == "HazardZone":
		if Globals.is_enabled(Globals.Mods.TUFF):
			being_pushed = true
			pusher = area.get_parent()
		else:
			_respawn(true)
	elif area.name == "DeathPlane":
		_respawn(false)

func _respawn(show_death_animation):
	if show_death_animation:
		get_tree().paused = true
		animation_player.play("death")
		await animation_player.animation_finished
		get_tree().paused = false
		
	var enemies = get_tree().get_nodes_in_group("Eggcups")
	for enemy in enemies:
		enemy.respawn()
		
	position = start_position
	animated_sprite_2d.self_modulate = Color(1,1,1,1)

func set_camera_limits(top, bot, left, right):
	camera.limit_top = top
	camera.limit_bottom = bot
	camera.limit_left = left
	camera.limit_right = right

func unsmooth_camera():
	camera.position_smoothing_enabled = false

func smooth_camera():
	camera.position_smoothing_enabled = true

func lock(x_velocity = SPEED/4):
	locked = true
	locked_x_velocity = x_velocity

func _glow():
	glowing = true
	modulate = Color(2, 2, 2)
	
func _unglow():
	glowing = false
	modulate = Color(1, 1, 1)

func _execute_noclip(delta):
	# Figure out a way to send Dee into the wall
	# and then plummeting into the chasm scene.
	print(velocity.x)
	var projected_x_velocity = (position.x - pusher.position.x) * delta
	print(projected_x_velocity)
	lock(projected_x_velocity)
	being_pushed = false
	gravity = 0
	collision_layer = 0
	collision_mask = 0
	$NoclipTimer.start()

func _on_hazard_checker_area_exited(area):
	being_pushed = false


func _on_noclip_timer_timeout():
	visible = false
	await get_tree().create_timer(1.0).timeout
	Globals.TransitionEdge = Globals.Edges.UNKNOWN
	Globals.TransitionVelocity = Vector2(0, 0)
	get_tree().change_scene_to_file("res://chasm.tscn")
