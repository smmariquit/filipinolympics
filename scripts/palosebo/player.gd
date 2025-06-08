extends ColorRect

var player_id: int = 0
var key: String = ""
var position_y: float = 1000.0
var climb_speed: float = 200.0 # Increased for smoother animation
var slip_speed: float = 300.0 # Increased for smoother animation
var is_climbing: bool = false
var is_slipping: bool = false
var target_y: float = 1000.0 # Target position for smooth movement

func _ready():
	# Set player ID based on name (Player1 -> 1, Player2 -> 2, etc.)
	player_id = int(name.substr(6))
	
	# Assign keys based on player ID
	match player_id:
		1: key = "A"
		2: key = "S"
		3: key = "D"
		4: key = "F"
		5: key = "J"
		6: key = "K"
		7: key = "L"
		8: key = ";"

func _process(delta):
	if is_climbing:
		# Smooth climbing animation
		position_y = move_toward(position_y, target_y, climb_speed * delta)
		position.y = position_y
		
		# Add slight wobble effect while climbing
		position.x = 320.0 + sin(Time.get_ticks_msec() * 0.01) * 2.0
		
		if position_y <= target_y:
			is_climbing = false
			if target_y <= 80: # Reached the flag
				get_parent().get_parent().player_won(player_id)
	
	elif is_slipping:
		# Smooth slipping animation
		position_y = move_toward(position_y, target_y, slip_speed * delta)
		position.y = position_y
		
		# Add wobble effect while slipping
		position.x = 320.0 + sin(Time.get_ticks_msec() * 0.02) * 4.0
		
		if position_y >= target_y:
			is_slipping = false
			position_y = target_y
			position.y = position_y
			position.x = 320.0 # Reset x position

func climb():
	is_climbing = true
	is_slipping = false
	target_y = position_y - 100.0 # Climb up by 100 pixels
	if target_y < 80: # Don't go above the flag
		target_y = 80.0

func slip():
	is_climbing = false
	is_slipping = true
	target_y = 1000.0 # Slip back to bottom