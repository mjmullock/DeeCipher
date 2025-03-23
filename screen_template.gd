extends Node2D

@export var camera_top_limit: int = -100000
@export var camera_bottom_limit: int = 100000
@export var camera_left_limit: int = -100000
@export var camera_right_limit: int = 100000

@export var default_spawn_position: Vector2

@onready var player = $Dee
@onready var bloom_layer = $BloomSprites
@onready var kaizo_dangers = $KaizoDangers
@onready var pause_shade = $PauseShade
@onready var ui_layer = $UIStuff
@onready var score = $UIStuff/Control/Score
@onready var dev_messages = $DevMessages

const RED_SHADE = Color(1, 0.2, 0.2)
const BLANK_SHADE = Color(1, 1, 1)

var base_screen_shade = BLANK_SHADE

# Called when the node enters the scene tree for the first time.
func _ready():
	player.set_camera_limits(
		camera_top_limit,
		camera_bottom_limit,
		camera_left_limit,
		camera_right_limit)
	
	player.unsmooth_camera()
	player.position = _get_spawn_position()
	print("Restored player position to %v" % player.position)
	player.velocity = Globals.TransitionVelocity
	player.smooth_camera()
	
	_update_score()

	bloom_layer.visible = Globals.is_enabled(Globals.Mods.BLOOM)
	dev_messages.visible = Globals.is_enabled(Globals.Mods.DOODLE)
	
	if Globals.is_enabled(Globals.Mods.KAIZO):
		kaizo_dangers.visible = true
		base_screen_shade = RED_SHADE
	else:
		base_screen_shade = BLANK_SHADE
		for node in get_tree().get_nodes_in_group("Kaizo"):
			node.collision_layer = 0
	
	pause_shade.color = base_screen_shade
	
	Events.pause_game.connect(_pause)
	Events.unpause_game.connect(_unpause)
	Events.points_acquired.connect(_update_score)
	
	_update_bloom_screens_found()

func _update_bloom_screens_found():
	match (name):
		"ScreenRightmost":
			Globals.BloomScreensFound[Globals.Edges.RIGHT] = null
		"ScreenLeftmost":
			Globals.BloomScreensFound[Globals.Edges.LEFT] = null
		"CloudsThree":
			Globals.BloomScreensFound[Globals.Edges.TOP] = null
		"ScreenPit":
			Globals.BloomScreensFound[Globals.Edges.BOTTOM] = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pause():
	pause_shade.color *= 0.5
	var pause_menu = load("res://pause_menu.tscn") as PackedScene
	ui_layer.add_child(pause_menu.instantiate())

func _unpause():
	pause_shade.color = base_screen_shade

func _update_score():
	score.text = "Score: %06d" % Globals.Points

func _get_spawn_position():
	var last_player_pos = Globals.TransitionPosition
	var edge_from = Globals.TransitionEdge
	if edge_from == Globals.Edges.UNKNOWN:
		# didn't go through a TransitionZone, so use the default point
		print("Using default spawn position")
		return default_spawn_position
	
	match edge_from:
		Globals.Edges.LEFT:
			# came from the left, so spawn on the right and preserve height
			return Vector2(camera_right_limit - 16, last_player_pos.y)
		Globals.Edges.RIGHT:
			return Vector2(camera_left_limit + 16, last_player_pos.y)
		Globals.Edges.TOP:
			return Vector2(last_player_pos.x, camera_bottom_limit - 16)
		Globals.Edges.BOTTOM:
			return Vector2(last_player_pos.x, camera_top_limit + 16)
			
