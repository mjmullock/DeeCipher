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

func enable(mod):
	if mod == Mods.ARGENT:
		ActiveMods = {}
	ActiveMods[mod] = null

func is_enabled(mod):
	return ActiveMods.has(mod)

func add_points(amount):
	Points += amount
