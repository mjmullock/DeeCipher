extends AnimatedSprite2D

const TEXT_TIME = 3.0;
const STATIC_TIME = 0.8;

var initialized = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	print(body)
	if body.name == "Dee" and not initialized:
		initialized = true
		_cycle_sign_text()

func _cycle_sign_text():
	play("default")
	await get_tree().create_timer(TEXT_TIME).timeout
	play("static")
	await get_tree().create_timer(STATIC_TIME).timeout
	play("two")
	await get_tree().create_timer(TEXT_TIME).timeout
	play("static")
	await get_tree().create_timer(STATIC_TIME).timeout
	play("three")
	await get_tree().create_timer(TEXT_TIME).timeout
	play("static")
	await get_tree().create_timer(STATIC_TIME).timeout
	_cycle_sign_text()
	
