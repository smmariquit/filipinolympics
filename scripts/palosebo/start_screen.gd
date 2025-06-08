extends Control

var player_count := 2

func _ready():
	# Connect button signals
	$MinusButton.pressed.connect(self._on_minus_pressed)
	$PlusButton.pressed.connect(self._on_plus_pressed)
	$StartButton.pressed.connect(self._on_start_pressed)
	update_player_count_display()

func _on_minus_pressed():
	if player_count > 2:
		player_count -= 1
		update_player_count_display()

func _on_plus_pressed():
	if player_count < 8:
		player_count += 1
		update_player_count_display()

func update_player_count_display():
	$PlayerCount.text = str(player_count) + " Players"

func _on_start_pressed():
	# Store player count in a global variable
	GameSettings.player_count = player_count
	# Change to main game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")
