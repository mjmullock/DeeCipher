extends CenterContainer

const MOD_MAPPING = {
	"BLOOM": Globals.Mods.BLOOM,
	"TUFF": Globals.Mods.TUFF,
	"TIPSY": Globals.Mods.TIPSY,
	"DOODLE": Globals.Mods.DOODLE,
	"KAIZO": Globals.Mods.KAIZO,
	"JUMPY": Globals.Mods.JUMPY,
	"ARGENT": Globals.Mods.ARGENT
}

const EASTER_EGG_NAMES = {
	"NOCLIP": "Gotta leave some challenge.",
	"JUSTINBAILEY": "Don't be lewd.",
	"KONAMI": "Wrong system, sadly.",
	"MOD NAME": "Nice try, though."
}

const GEM_PASSWORDS = {}

const MAX_NAME_LENGTH = 12

@onready var text_entry = $VBoxContainer/HBoxContainer/TextEdit
@onready var mod_check_button = $VBoxContainer/HBoxContainer/Button
@onready var menu_button = $VBoxContainer/HBoxContainer/MenuButton
@onready var mod_grid = $VBoxContainer/ModGrid
@onready var validity = $VBoxContainer/ValidityMessage

# Called when the node enters the scene tree for the first time.
func _ready():
	text_entry.grab_focus()
	for mod in Globals.ActiveMods:
		activate_mod(mod)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func lock_page():
	text_entry.editable = false
	mod_check_button.disabled = true
	menu_button.focus_neighbor_left = menu_button.get_path()
	menu_button.focus_neighbor_right = menu_button.get_path()
	menu_button.grab_focus()
	

func _on_button_pressed():
	var entered_mod_name = text_entry.text.strip_edges().to_upper()
	text_entry.text = ""
	if entered_mod_name == "":
		return
	elif entered_mod_name == "CALC":
		_load_calc_page()
		return

	if MOD_MAPPING.has(entered_mod_name):
		var mod = MOD_MAPPING[entered_mod_name]
		if Globals.KnownMods.has(mod):
			validity.text = "Mod %s is already listed." % entered_mod_name
		else:
			Globals.KnownMods[mod] = null
			activate_mod(mod)
	else:
		validity.text = "Unknown mod name: %s" % entered_mod_name
		if EASTER_EGG_NAMES.has(entered_mod_name):
			validity.text += "  (%s)" % EASTER_EGG_NAMES[entered_mod_name]


func activate_mod(mod):
	var cells = mod_grid.get_children()
	var cell_index = mod
	for i in range(3):
		cells[3 * cell_index + i].visible = true
	Globals.enable(mod)
	
	if mod == Globals.Mods.ARGENT:
		for i in range(Globals.Mods.ARGENT * 3):
			cells[i].visible = false
		lock_page()


func _on_text_edit_text_changed():
	validity.text = ""
	var t = text_entry.text
	
	# override 'Enter' key behavior to submit a guess
	if t.ends_with("\n"):
		_on_button_pressed()
		return
	
	#override 'Tab' key to leave text entry
	if t.ends_with("\t"):
		text_entry.text = t.replace("\t", "")
		mod_check_button.grab_focus()
		
	if t.length() > MAX_NAME_LENGTH:
		text_entry.text = t.substr(0, MAX_NAME_LENGTH)
		text_entry.set_caret_column(MAX_NAME_LENGTH)


func _on_menu_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	FadeAnimator.fade_from_black()


func _load_calc_page():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://mod_calc_page.tscn")
	FadeAnimator.fade_from_black()

func _toggle_mod(mod):
	var cells = mod_grid.get_children()
	var index = 3 * mod
	
	if Globals.ActiveMods.has(mod):
		Globals.ActiveMods.erase(mod)
		cells[index].self_modulate = Color(1,1,1,.5)
		cells[index+1].self_modulate = Color(1,1,1,.5)
		cells[index+2].self_modulate = Color(1,1,1,.5)
		cells[index+2].texture_normal.pause = true
	else:
		Globals.ActiveMods[mod] = null
		cells[index].self_modulate = Color(1,1,1)
		cells[index+1].self_modulate = Color(1,1,1)
		cells[index+2].self_modulate = Color(1,1,1)
		cells[index+2].texture_normal.pause = false

func _on_bloom_button_pressed():
	_toggle_mod(Globals.Mods.BLOOM)

func _on_tuff_button_pressed():
	_toggle_mod(Globals.Mods.TUFF)

func _on_tipsy_button_pressed():
	_toggle_mod(Globals.Mods.TIPSY)

func _on_doodle_button_pressed():
	_toggle_mod(Globals.Mods.DOODLE)

func _on_kaizo_button_pressed():
	_toggle_mod(Globals.Mods.KAIZO)

func _on_jumpy_button_pressed():
	_toggle_mod(Globals.Mods.JUMPY)
