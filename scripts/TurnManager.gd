extends Node
class_name TurnManager          # autoload this script

signal turn_changed(active_id)
signal dice_result(value, player_id)

var players : Array[int] = []   # [1, 2, 4 …]   (host id = 1)
var turn_idx : int = 0

func _ready() -> void:
	if multiplayer.is_server():
		var peers := multiplayer.get_peers()      # PackedInt32Array
		players  = [1]                            # host first
		players.append_array(peers)               # merge arrays
		_broadcast_turn()

# ——————————————————————————————————————————
@rpc("any_peer")
func ask_roll() -> void:
	if !multiplayer.is_server(): return

	var caller := multiplayer.get_remote_sender_id()
	if caller != players[turn_idx]: return        # not his turn

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var value := rng.randi_range(1, 6)

	# TODO: host-side board update here …

	# next turn
	turn_idx = (turn_idx + 1) % players.size()
	_broadcast_result(value, caller)
	_broadcast_turn()

# helpers
func _broadcast_result(value:int, who:int) -> void:
	rpc("dice_result", value, who)
	emit_signal("dice_result", value, who)

func _broadcast_turn() -> void:
	var id := players[turn_idx]
	rpc("set_turn", id)
	emit_signal("turn_changed", id)

@rpc("authority") func set_turn(active_id:int) -> void:
	emit_signal("turn_changed", active_id)
