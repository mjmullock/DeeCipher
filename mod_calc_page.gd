extends CenterContainer

@onready var word_input = $VBoxContainer/HBoxContainer/WordInput
@onready var modulus_input = $VBoxContainer/HBoxContainer/ModulusInput
@onready var result_label = $VBoxContainer/ResultLabel

const ALPHA_OFFSET = 65 # "A".unicode_at(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	word_input.grab_focus()

func _on_compute_button_pressed():
	var word = word_input.text.to_upper()
	var modulus = modulus_input.text.to_upper()
	
	if word == "" or modulus == "":
		result_label.text = "Both a word and modulus must be listed."
		return
	
	if not _is_valid(word):
		result_label.text = "Non-alphabetic word: '%s'" % word
	elif not _is_valid(modulus):
		result_label.text = "Non-alphabetic modulus: '%s'" % modulus
	elif modulus in ["A", "B"]:
		result_label.text = "Bad modulus: '%s', need higher value" % modulus
	else:
		result_label.text = "%s MOD %s == %s" % [
			word, modulus, _alphabetic_mod(word, modulus)]

func _is_valid(s):
	# String 's' should only contain uppercase alphabetic chars, A-Z.
	var regex = RegEx.new()
	regex.compile("[^A-Z]")
	var result = regex.search(s)
	return (result == null) and (s.length() > 0)

func _alphabetic_mod(word, modulus):
	var word_value = 0
	var multiplier = 0
	for char in word.reverse():
		word_value += pow(26, multiplier) * _char_to_value(char)
		multiplier += 1
	
	var result = int(word_value) % _char_to_value(modulus)
	print(result)
	print(_value_to_char(result))
	return _value_to_char(result)

func _char_to_value(c):
	print("_char_to_value")
	print(c)
	print(c.unicode_at(0))
	return c.unicode_at(0) - ALPHA_OFFSET

func _value_to_char(v):
	return String.chr(v + ALPHA_OFFSET)


func _on_main_menu_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	FadeAnimator.fade_from_black()


func _on_mod_mgr_button_pressed():
	await FadeAnimator.fade_to_black()
	get_tree().change_scene_to_file("res://mod_page.tscn")
	FadeAnimator.fade_from_black()
