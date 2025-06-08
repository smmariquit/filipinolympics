extends Node

@onready var btn_play   := $VBoxContainer/VBoxContainer/StartGameContainer/StartGameButton
@onready var host_btn   := $VBoxContainer/VBoxContainer/HostingAndJoinGameContainer/VBoxContainer/HostGameButton
@onready var join_btn   := $VBoxContainer/VBoxContainer/HostingAndJoinGameContainer/VBoxContainer/VBoxContainer/JoinGameButton
@onready var ip_field   := $VBoxContainer/VBoxContainer/HostingAndJoinGameContainer/VBoxContainer/VBoxContainer/IPLineEdit
@onready var status_lbl := $VBoxContainer/VBoxContainer/StatusLabel
@onready var join_box   := $VBoxContainer/VBoxContainer/HostingAndJoinGameContainer

func _ready():
	join_box.visible = false
	btn_play.pressed.connect(_show_online)

	host_btn.pressed.connect(_host)
	join_btn.pressed.connect(_join)

	NetworkManager.connected.connect(_on_connected)
	NetworkManager.peer_joined.connect(_on_new_peer)

func _show_online():
	btn_play.visible = false
	join_box.visible = true

func _host():
	status_lbl.text = "⏳ Hosting..."
	NetworkManager.host()                   # localhost server

func _join():
	var code: String = ip_field.text.strip_edges()
	if not code.is_valid_int():
		status_lbl.text = "⚠ Port number lang (ex 6604)";  return

	var port := int(code)
	var host: String = NetworkManager.PLAYIT_HOST

	print("🔗 Connect →", host, ":", port)
	status_lbl.text = "⏳ Connecting..."
	NetworkManager.join(host, port)


func _on_connected():
	status_lbl.text = "✅ Hosting (waiting)..." if NetworkManager.is_host else "✅ Connected!"
	print("🌐 CONNECTED  (is_host =", NetworkManager.is_host, ")")
	await get_tree().create_timer(1).timeout
	NetworkManager.go_to_lobby()

func _on_new_peer(id:int):
	status_lbl.text = "🎉 Player %d joined!" % id
	
func go_to_lobby():
	var lobby := preload("res://scenes/ui/LobbyUi.tscn")
	get_tree().change_scene_to_packed(lobby)
