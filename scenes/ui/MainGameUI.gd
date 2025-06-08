extends Control

enum EventType { NONE, MOVE_UP, HOLE, LEAVES, SUNGKA, PALOSEBO, VIDEOKE, PALAYOK }

@onready var roll_btn : TextureButton = $VBoxContainer/VBoxContainer/StartGameButtonContainer/StartGameButton

@onready var btn_roll : TextureButton = $VBoxContainer/VBoxContainer/StartGameButtonContainer/StartGameButton
@onready var popup    : DicePopup     = $DicePopup
@onready var token    : Sprite2D      = $VBoxContainer/VBoxContainer/CenterContainer2/Node2D/PlayerToken
@onready var markers  : Node2D        = $VBoxContainer/VBoxContainer/CenterContainer2/Board/TileMarkers

const MAX_TILE := 42
var tile_centers : Array[Vector2] = []
var current_tile : int = 1

func _ready() -> void:
	PlayerTurnManager.turn_changed.connect(_on_turn)
	PlayerTurnManager.dice_result.connect(_on_dice)
	_on_turn(-1)    
	
	await get_tree().process_frame
	_cache_marker_positions()

	token.global_position = _pos_for(current_tile)

	btn_roll.pressed.connect(_roll_dice)
	popup.roll_finished.connect(_on_roll_result)

func _on_turn(active_id:int) -> void:
	roll_btn.disabled = (multiplayer.get_unique_id() != active_id)
	
func _cache_marker_positions():
	tile_centers.clear()
	for i in range(1, MAX_TILE + 1):
		var m := markers.get_node("Tile%d" % i) as Marker2D
		tile_centers.append(m.global_position)

func _pos_for(idx:int) -> Vector2: return tile_centers[idx - 1]

# ─────────────────────  DICE & MOVE  ────────────────────────────────
func _roll_dice(): btn_roll.disabled = true; popup.start_roll()

func _on_roll_result(value:int) -> void:
	btn_roll.disabled = false

	var next:int = clamp(current_tile + value, 1, MAX_TILE)
	await _move_to(next)          # first move
	current_tile = next
	await _check_event(current_tile)

func _move_to(tile:int) -> void:
	var dest := _pos_for(tile)
	await create_tween()\
		.tween_property(token, "global_position", dest, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)\
		.finished

# ─────────────────────  EVENT CHECK  ────────────────────────────────
func _check_event(tile:int) -> void:
	var marker := markers.get_node("Tile%d" % tile) as Marker2D
	var etype  : int  = marker.get_meta("event_type",  EventType.NONE)
	var target : int  = marker.get_meta("target_tile", -1)

	match etype:
		EventType.MOVE_UP:
			if target > 0: print("Ladder:", tile, "➜", target)

		EventType.HOLE:
			if target > 0: print("Hole:", tile, "➜", target)

		EventType.LEAVES, EventType.SUNGKA, EventType.PALOSEBO, EventType.VIDEOKE, EventType.PALAYOK:        # ← ONE line!
			print("Mini-game on tile", tile, "=", etype)

	if target > 0:
		await _move_to(target)
		current_tile = target
