extends Control

@onready var result_label = $MarginContainer/ResultLabel
@onready var gems_label = $MarginContainer/GemsLabel
@onready var conclusion_label = $MarginContainer/ConclusionLabel
@onready var conclusion_label_copy = $MarginContainer/ConclusionLabel2
@onready var hint_label = $MarginContainer/HintLabel
@onready var final_picture = $MarginContainer/FinalPicture
@onready var menu_message = $MarginContainer/ReturnToMenuLabel
@onready var timer = $Timer
@onready var menu_timer = $Timer2

const BASE_GOAL_ACHIEVED = "You made it safely back home."
const FINAL_GOAL_ACHIEVED = "You solved all the puzzles, and recovered an important family treasure."
const GEMS_PREFIX = "You also collected "
const NOT_FINISHED_MESSAGE = "There may be more to find..."
const THANK_YOU_MESSAGE = "Thank you for playing DeeCipher."

const UNKNOWN_HINT = """
This message should not appear. It's not a puzzle, or an intended glitch.

Please let the developer know that you're seeing it, along with where you are
and what steps you took to see it. And rest easy, knowing you found an edge case
that nobody caught during testing so far!
"""

const ARGENT_HINT = """
You skipped the Silver Key.

Why? How?? Did you think you would be rewarded for this interaction?

No. Go get that key and finish the game properly. Come on now.
"""

const JUMPY_HINT = """
Double-jumping is a powerful skill. But do you need to stop at two jumps?

A certain doodled message might be useful here...
"""
const JUMPY_HINT_DECODE = """
Have you reached everywhere you can? Then a bit of math may be in order.

Make sure you've understood the simple examples, and don't be afraid to
rely on a calculator. There's even a special one in-game! Did you find it?
"""

const KAIZO_HINT = """
Well done getting through a brutally difficult level. It needed a lot
of precise jumpwork, especially in those [b]Red-bordered sections[/b].

I could hear the key taps all the way from here!

Like, hop. Hop. Juuump_ ...
"""

const DOODLE_HINT = """
That dev sure had a lot to say. But it's important to filter out the
important messages from among them.

All of the doodles marked with a [b]green spiral[/b] seem to have a common theme...
"""

const TIPSY_HINT = """
Poor eggcups, stuck spinning in the air. Unless you sent some of them
flying off into the distance, of course.

Or maybe you sent them into each other?
"""
const TIPSY_HINT_DECODE = """
Look at the eggcups bounce back and forth! You have to feel bad for them.

Enemies aren't [b]flags[/b], of course, but still...
"""

const TUFF_HINT = """
Eggcups can't hurt you now. You can even push them around!

Or maybe let them push [i]you[/i] around.

Just be careful not to squish against a wall. What would even happen...?
"""
const TUFF_HINT_DECODE = """
The garbage collection plane can be a scary place. Lots of debris and prototype
versions of objects...

The first iteration of Dee's house almost had a different name. Can you guess it?
"""

const BLOOM_HINT = """
Did you enjoy seeing all of the flowers?

And did you keep an eye out for those 'favorite' flowers, the [b]Blue Diamonds[/b]?

You may need to venture beyond them...
"""
const BLOOM_HINT_DECODE = """
Once you've found some new screens, keep a careful count of what's there.

Don't let any fossil or cloud or fish or crevice escape your notice.

Then, consider how you might arrange what you get.
"""

const NO_MODS_MESSAGE = """
Mods change how this game works, and using them may let you see new things.
Try to find as many as you can!

Most mod names are hidden. But to get started, enter the name
[b]BLOOM[/b]
in the Mod Manager to improve the graphics.
"""

var is_game_complete = false
var can_return_to_menu = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	is_game_complete = Globals.is_enabled(Globals.Mods.ARGENT) and Globals.HasSilverKey
	if is_game_complete:
		result_label.text = FINAL_GOAL_ACHIEVED
		conclusion_label.text = THANK_YOU_MESSAGE
		conclusion_label_copy.text = THANK_YOU_MESSAGE
	else:
		result_label.text = BASE_GOAL_ACHIEVED
		conclusion_label.text = NOT_FINISHED_MESSAGE
		conclusion_label_copy.text = NOT_FINISHED_MESSAGE
	
	var gem_count = Globals.CollectedGems.size()
	match (gem_count):
		0:
			gems_label.text = ""
		1:
			gems_label.text = GEMS_PREFIX + "1 gem. Nice!"
		2,3:
			gems_label.text = GEMS_PREFIX + gem_count + " gems. Nice!"
		4,5:
			gems_label.text = GEMS_PREFIX + gem_count + " gems. Well done!"
		6,7:
			gems_label.text = GEMS_PREFIX + gem_count + " gems. Extraordinary!"
		8:
			gems_label.text = GEMS_PREFIX + "8 gems. That's all of them!"

func _process(_delta):
	if can_return_to_menu and Input.is_action_just_pressed("ui_accept"):
		Globals.TransitionEdge = Globals.Edges.UNKNOWN
		await FadeAnimator.fade_to_black()
		get_tree().change_scene_to_file("res://start_menu.tscn")
		FadeAnimator.fade_from_black()

func _on_timer_timeout():
	var target_position = result_label.position
	result_label.queue_free()
	gems_label.queue_free()
	var tween = create_tween()
	tween.tween_property(conclusion_label, "position", target_position, 2)
	tween.tween_callback(_show_hint_or_picture)

func _show_hint_or_picture():
	conclusion_label.queue_free()
	conclusion_label_copy.show()
	if is_game_complete:
		final_picture.show()
	else:
		hint_label.show()
		hint_label.text = _center(_get_hint_text())
		
	menu_timer.start()

func _center(rich_text):
	return "[center]%s[/center]" % rich_text

func _get_hint_text():
	var mods = Globals.KnownMods.keys()
	if (mods.size() == 0):
		return NO_MODS_MESSAGE
		
	mods.sort()
	match(mods.max()):
		Globals.Mods.ARGENT:
			return ARGENT_HINT
		Globals.Mods.JUMPY:
			if Globals.HasReachedMeta:
				return JUMPY_HINT_DECODE
			return JUMPY_HINT
		Globals.Mods.KAIZO:
			return KAIZO_HINT
		Globals.Mods.DOODLE:
			return DOODLE_HINT
		Globals.Mods.TIPSY:
			if Globals.HasCollidedTipsies:
				return TIPSY_HINT_DECODE
			return TIPSY_HINT
		Globals.Mods.TUFF:
			if Globals.HasNoClipped:
				return TUFF_HINT_DECODE
			return TUFF_HINT
		Globals.Mods.BLOOM:
			if Globals.BloomScreensFound.keys().size() == 4:
				return BLOOM_HINT_DECODE
			return BLOOM_HINT
		_:
			return UNKNOWN_HINT


func _on_timer_2_timeout():
	can_return_to_menu = true
	menu_message.show()
