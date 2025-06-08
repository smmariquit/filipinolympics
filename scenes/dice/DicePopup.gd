extends CanvasLayer
class_name DicePopup

@export var dice_faces_path : String        = "res://assets/dice_faces"   # folder
@onready var dice_face  : TextureRect = $Panel/CenterContainer/DiceFace
@onready var shuffle_t  : Timer       = $ShuffleTimer

signal roll_finished(value:int)

var _faces : Array[Texture2D]
var _rng   := RandomNumberGenerator.new()
var _loops := 15                       # ilang beses mag-flash bago huminto

func _ready():
	# Pre-load all PNG faces
	var dir := DirAccess.open(dice_faces_path)
	for file_name in dir.get_files():
		if file_name.ends_with(".png"):
			_faces.append(load("%s/%s" % [dice_faces_path, file_name]))
	shuffle_t.timeout.connect(_on_shuffle)

func start_roll():
	visible = true
	_loops  = 15
	shuffle_t.start()                  # magsisimula ang flashing

func _on_shuffle():
	# Flash another random face
	dice_face.texture = _faces.pick_random()
	_loops -= 1
	if _loops <= 0:
		shuffle_t.stop()
		var result := _faces.find(dice_face.texture) + 1   # 1-6
		await get_tree().create_timer(0.3).timeout         # konting delay
		visible = false
		emit_signal("roll_finished", result)
