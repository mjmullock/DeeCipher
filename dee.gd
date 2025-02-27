extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var start_position = global_position

const SPEED = 150.0
const JUMP_VELOCITY = -320.0

enum PlayerState {
	# Default state. Movement and action buttons affect the character.
	CONTROLLABLE,
	
	# Character velocity is preset, movement and action buttons are ignored.
	# Character is still subject to gravity and collision.
	FORCE_MOVE,
	
	# Character position is forced to given values.
	# Movement and action buttons are ignored.
	# Character ignores gravity and collision.
	FORCE_REPOSITION
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var state: PlayerState = PlayerState.CONTROLLABLE
var forced_velocity = Vector2(0, 0)
var forced_position_delta = Vector2(0, 0)
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
	
	if Input.is_action_just_pressed("ui_mod_check"):
		print("Mod check")
		print(Globals.ActiveMods)
	
func _physics_process(delta):
	if being_pushed and _is_being_squished():
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

	if state == PlayerState.FORCE_MOVE:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.speed_scale = 0.5
		velocity.x = forced_velocity.x
		velocity.y = current_velocity.y + gravity * delta
		move_and_slide()
	elif state == PlayerState.FORCE_REPOSITION:
		animated_sprite_2d.play("idle")
		position += forced_position_delta
	else:
		if being_pushed:
			velocity += pusher.velocity
		update_animation(direction)
		move_and_slide()

func _is_being_squished():
	return _raycast(-1) and _raycast(1)

func _raycast(direction):
	var space_state = get_world_2d().direct_space_state
	var target = Vector2(global_position.x + 10 * direction, global_position.y)
	var ray_params = PhysicsRayQueryParameters2D.create(global_position, target)
	ray_params.exclude = [self]
	return space_state.intersect_ray(ray_params)

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
	if area.name == "KaizoHazardZone":
		_respawn(true)
	elif area.name == "HazardZone":
		if Globals.is_enabled(Globals.Mods.TIPSY):
			print("Fire away!")
			var projectile_body = area.get_parent()
			var fire_vector = (projectile_body.global_position - global_position)
			projectile_body.fire(fire_vector)
			
		elif Globals.is_enabled(Globals.Mods.TUFF):
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

func start_force_move(x_velocity = SPEED/4, y_velocity = 0):
	state = PlayerState.FORCE_MOVE
	forced_velocity = Vector2(x_velocity, y_velocity)

func start_force_reposition(pos_delta):
	state = PlayerState.FORCE_REPOSITION
	forced_position_delta = pos_delta
	being_pushed = false
	gravity = 0
	collision_layer = 0
	collision_mask = 0

func _glow():
	glowing = true
	modulate = Color(2, 2, 2)
	
func _unglow():
	glowing = false
	modulate = Color(1, 1, 1)

func _execute_noclip(delta):
	# Figure out a way to send Dee into the wall
	# and then plummeting into the chasm scene.
	var projected_x_velocity = (position.x - pusher.position.x) * delta
	print(projected_x_velocity)
	start_force_reposition(Vector2(projected_x_velocity, 0))
	$NoclipTimer.start()

func _on_hazard_checker_area_exited(area):
	being_pushed = false


func _on_noclip_timer_timeout():
	# visible = false
	forced_position_delta = Vector2(0, 1)
	await get_tree().create_timer(1.0).timeout
	Globals.HasNoClipped = true
	Globals.TransitionEdge = Globals.Edges.UNKNOWN
	Globals.TransitionVelocity = Vector2(0, 0)
	get_tree().change_scene_to_file("res://chasm.tscn")
