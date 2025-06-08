@tool
extends Node2D

enum EventType { NONE, MOVE_UP, HOLE, LEAVES, SUNGKA, PALOSEBO, VIDEOKE, PALAYOK }

const ICONS := {
	EventType.MOVE_UP  : preload("res://assets/tile_types/ladder.png"),
	EventType.HOLE     : preload("res://assets/tile_types/HOLE.png"),
	EventType.LEAVES   : preload("res://assets/tile_types/LEAVES.png"),
	EventType.SUNGKA   : preload("res://assets/tile_types/SUNGKA.png"),
	EventType.PALOSEBO : preload("res://assets/tile_types/PALOSEBO.png"),
	EventType.VIDEOKE  : preload("res://assets/tile_types/VIDEOKE.png"),
	EventType.PALAYOK  : preload("res://assets/tile_types/PALAYOK.png"),
}

# ─── TWEAKABLE VALUES (Inspector) ────────────────────────────────────
@export var prob_moveup : float =  7.0 
@export var prob_hole   : float =  7.0
@export var prob_mini   : float = 18.0
@export var icon_scale  : float = 0.25

# board constants
const START_TILE  := 1
const FINISH_TILE := 42
const COLS        := 7

const MINI_EVENTS = [
	EventType.LEAVES, EventType.SUNGKA,
	EventType.PALOSEBO, EventType.VIDEOKE, EventType.PALAYOK,
]

@onready var markers : Node2D                = $"../TileMarkers"
@onready var rng     : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready()             -> void: _spawn_icons()
func _notification(w:int) -> void:
	if w == NOTIFICATION_POSTINITIALIZE: _spawn_icons()

# ─── MAIN BUILD PHASE ────────────────────────────────────────────────
var _bag : Array = []

func _spawn_icons() -> void:
	# clear old icons & meta data
	for c in get_children(): c.queue_free()
	
	for m in markers.get_children():
		m.set_meta("event_type", null)
		m.set_meta("target_tile", null)

	# gather & shuffle candidate tiles (2 .. 41)
	var cand := []
	for t in range(START_TILE + 1, FINISH_TILE):
		cand.append(t)
	rng.randomize()
	_bag = cand.duplicate()
	_bag.shuffle()

	# decide counts
	var total := cand.size()                         # 40
	var cnt_up   := roundi(total * prob_moveup / 100.0)
	var cnt_hole := roundi(total * prob_hole   / 100.0)
	var cnt_mini := roundi(total * prob_mini   / 100.0)

	var events : Dictionary = {}        # logical_tile → [etype, target]

	# ladders
	for tile in _take(cnt_up):
		events[tile] = [EventType.MOVE_UP, _above(tile)]

	# holes
	for tile in _take(cnt_hole):
		events[tile] = [EventType.HOLE,    _below(tile)]

	# mini-games (round-robin)
	var cycle := MINI_EVENTS.duplicate()
	for tile in _take(cnt_mini):
		if cycle.is_empty(): cycle = MINI_EVENTS.duplicate()
		events[tile] = [cycle.pop_front(), null]

	# create icons *and* embed meta on the matching Marker2D
	for tile in events.keys():
		var etype  : int = events[tile][0]
		var target = events[tile][1]

		var marker : Marker2D = markers.get_node_or_null("Tile%d" % tile)
		if marker == null: continue

		# store meta for gameplay script
		marker.set_meta("event_type",  etype)
		marker.set_meta("target_tile", target)

		# spawn icon
		var tex : Texture2D = ICONS.get(etype, null)
		if tex == null: continue

		var s := Sprite2D.new()
		s.name     = "Icon_%d" % tile
		s.texture  = tex
		s.centered = true
		s.position = marker.position
		s.scale    = Vector2(0.03, 0.03)
		s.z_index  = 1
		add_child(s)

# ─── HELPERS ─────────────────────────────────────────────────────────
func _take(n:int) -> Array:
	var out := []
	for _i in n:
		if _bag.is_empty(): break
		out.append(_bag.pop_back())
	return out

func _above(tile:int)  -> int: return min(tile + COLS, FINISH_TILE - 1)
func _below(tile:int)  -> int: return max(tile - COLS, START_TILE  + 1)
