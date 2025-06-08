extends Control

@onready var ip_label      : Label          = $VBoxContainer2/CenterContainer/LogoContainer/IPLabel
@onready var slots_box     : VBoxContainer  = $VBoxContainer2/CenterContainer/PlayerListsContainer
@onready var start_button  : TextureButton         = $VBoxContainer2/CenterContainer/StartGameButtonContainer/StartGameButton

func _ready():
	_populate_ip()
	_refresh_player_list()

	# Live updates
	NetworkManager.peer_joined.connect(_on_peer_update)
	multiplayer.peer_disconnected.connect(_on_peer_update)

	start_button.disabled = !NetworkManager.is_host
	start_button.pressed.connect(_on_start_pressed)

func _populate_ip():
	if NetworkManager.is_host:
		ip_label.text = "ROOM CODE :  " + NetworkManager.ROOM_CODE
	else:
		ip_label.text = "Connected to host"

func _refresh_player_list():
	print("👥 refreshing player list...")
	_slot_label(0).text = "Player 1 (Host)"
	
	for i in range(1, slots_box.get_child_count()):
		_slot_label(i).text = "Waiting..."

	var idx := 1
	for id in multiplayer.get_peers():
		if id == 1: continue
		if idx < slots_box.get_child_count():
			_slot_label(idx).text = "Player %d" % (idx + 1)
			idx += 1
			
	print("   current peers:", multiplayer.get_peers())
			
func _slot_label(idx:int) -> Label:
	var slot := slots_box.get_child(idx)
	return slot.get_node("PlayerName") as Label

func _on_peer_update(_id := 0):
	_refresh_player_list()

func _on_start_pressed():
	if NetworkManager.is_host:
		print("▶️ Host pressed START – rpc to all")
		NetworkManager.rpc("start_board") 
			
