extends Node

enum Mods {BLOOM, TUFF, TIPSY, DOODLE, KAIZO, JUMPY, ARGENT}

enum Edges {LEFT, RIGHT, TOP, BOTTOM, UNKNOWN}

var KnownMods = {}
var ActiveMods = {}
var CollectedGems = {}
var CollectedCoins = {}

var TransitionEdge: Edges = Edges.UNKNOWN
var TransitionPosition: Vector2
var TransitionVelocity: Vector2
var Points = 0
var Permajump = false
var HasSilverKey = false

var BloomScreensFound = {}
var HasNoClipped = false
var HasCollidedTipsies = false
var HasReachedMeta = false

var play_music = true
var play_sfx = true
var trans_delay = 0

func enable(mod):
	if mod == Mods.ARGENT:
		ActiveMods = {}
	ActiveMods[mod] = null

func is_enabled(mod):
	return ActiveMods.has(mod)

func add_points(amount):
	Points += amount

func set_play_music(val):
	play_music = val
	if val == false:
		MusicMixer.stop_all()
	else:
		MusicMixer.play_title()

func set_play_sfx(val):
	play_sfx = val
	if val == true:
		SfxMixer.play_coin()
