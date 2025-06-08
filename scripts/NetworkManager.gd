extends Node
class_name Net

const PLAYIT_HOST : String = "build-reggae.gl.at.ply.gg"
const PLAYIT_PORT : int    = 6604
var ROOM_CODE   : String = "6604"

signal connected
signal peer_joined(id)

var is_host : bool = false

func host(port:int = 12345):
	print("🖥️  HOST: opening local server @", port)
	var peer := ENetMultiplayerPeer.new()
	var ok   := peer.create_server(port, 4)
	if ok != OK:
		push_error("❌ create_client failed code %d" % ok)
		return
	multiplayer.multiplayer_peer = peer
	is_host = true
	_setup_signals()
	print("🖥️  HOST ready – peer id:", multiplayer.get_unique_id())
	emit_signal("connected")

func join(ip:String, port:int):
	print("🔗 JOIN: try connect →", ip, ":", port)
	var peer := ENetMultiplayerPeer.new()
	var ok   := peer.create_client(ip, port)
	if ok != OK:
		push_error("❌ create_client failed code %d" % ok)
		return
	multiplayer.multiplayer_peer = peer
	is_host = false
	_setup_signals()

func _setup_signals():
	multiplayer.connected_to_server.connect( func(): 
		print("✅ connected_to_server  (id =", multiplayer.get_unique_id(), ")")
		emit_signal("connected") 
	)
	multiplayer.peer_connected.connect(_on_peer)
	multiplayer.peer_disconnected.connect(_on_peer)

func _on_peer(id:int):
	if is_host: emit_signal("peer_joined", id)

# handy helper
func go_to_board():
	var scene := preload("res://scenes/ui/MainGameUI.tscn")
	get_tree().change_scene_to_packed(scene)
	
func go_to_lobby():
	var lobby := preload("res://scenes/ui/LobbyUi.tscn")
	get_tree().change_scene_to_packed(lobby)
	

@rpc("authority") func start_board():
	go_to_board()
