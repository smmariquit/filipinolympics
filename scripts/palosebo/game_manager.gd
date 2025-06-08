extends Control

var current_question: Dictionary
var active_players: Array = []
var game_active: bool = false
var current_player: int = 1 # Track whose turn it is
var question_timer: float = 0.0
var max_question_time: float = 10.0 # 10 seconds per question

# Sample Filipino trivia questions with multiple choice
var questions = [
	{
		"question": "What is the national flower of the Philippines?",
		"choices": ["Sampaguita", "Rose", "Orchid", "Tulip"],
		"correct_index": 0
	},
	{
		"question": "What is the capital city of the Philippines?",
		"choices": ["Cebu", "Manila", "Davao", "Quezon City"],
		"correct_index": 1
	},
	{
		"question": "What is the largest island in the Philippines?",
		"choices": ["Mindanao", "Luzon", "Visayas", "Palawan"],
		"correct_index": 1
	},
	{
		"question": "What is the traditional Filipino martial art?",
		"choices": ["Kung Fu", "Arnis", "Karate", "Taekwondo"],
		"correct_index": 1
	},
	{
		"question": "What is the national bird of the Philippines?",
		"choices": ["Maya", "Philippine Eagle", "Cockatoo", "Hornbill"],
		"correct_index": 1
	},
	{
		"question": "What is the traditional Filipino dance that uses bamboo poles?",
		"choices": ["Cariñosa", "Tinikling", "Pandanggo", "Sayaw sa Bangko"],
		"correct_index": 1
	},
	{
		"question": "What is the oldest city in the Philippines?",
		"choices": ["Manila", "Cebu", "Davao", "Quezon City"],
		"correct_index": 1
	},
	{
		"question": "What is the national fruit of the Philippines?",
		"choices": ["Banana", "Mango", "Pineapple", "Durian"],
		"correct_index": 1
	},
	{
		"question": "What is the traditional Filipino rice cake wrapped in banana leaves?",
		"choices": ["Bibingka", "Suman", "Puto", "Kutsinta"],
		"correct_index": 1
	},
	{
		"question": "What is the national hero of the Philippines?",
		"choices": ["Andres Bonifacio", "Jose Rizal", "Emilio Aguinaldo", "Lapu-Lapu"],
		"correct_index": 1
	},
	{
		"question": "What is the traditional Filipino Christmas lantern?",
		"choices": ["Parol", "Lampin", "Ilaw", "Sulo"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino noodle dish?",
		"choices": ["Pancit", "Spaghetti", "Ramen", "Udon"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino rice porridge?",
		"choices": ["Lugaw", "Congee", "Arroz Caldo", "Goto"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino street food made from chicken intestines?",
		"choices": ["Isaw", "Betamax", "Kwek-kwek", "Fishball"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino dessert made from shaved ice?",
		"choices": ["Halo-halo", "Ice cream", "Sorbetes", "Mais con yelo"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino breakfast dish?",
		"choices": ["Tapsilog", "Pancakes", "Cereal", "Toast"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino rice wine?",
		"choices": ["Tuba", "Beer", "Wine", "Whiskey"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino musical instrument made from bamboo?",
		"choices": ["Kulintang", "Angklung", "Guitar", "Piano"],
		"correct_index": 1
	},
	{
		"question": "What is the traditional Filipino board game?",
		"choices": ["Sungka", "Chess", "Checkers", "Monopoly"],
		"correct_index": 0
	},
	{
		"question": "What is the traditional Filipino children's game with rubber bands?",
		"choices": ["Chinese Garter", "Patintero", "Tumbang Preso", "Luksong Tinik"],
		"correct_index": 0
	}
]

func _ready():
	# Get player count from settings
	var player_count = get_node("/root/GameSettings").player_count
	
	# Initialize active players based on player count
	for i in range(1, player_count + 1):
		active_players.append(i)
		get_node("Players/Player" + str(i)).visible = true
	
	# Hide unused players
	for i in range(player_count + 1, 9):
		get_node("Players/Player" + str(i)).visible = false
	
	# Connect choice button signals
	for i in range(4):
		var choice_button = get_node("QuestionPanel/VBox/Choice" + str(i + 1))
		choice_button.pressed.connect(_on_choice_pressed.bind(i))
	
	# Start the game
	start_game()

func _process(delta):
	if game_active:
		question_timer -= delta
		update_timer_display()
		
		if question_timer <= 0:
			time_up()

func _input(event):
	if not game_active:
		return
		
	if event is InputEventKey and event.pressed:
		# Handle keyboard input for choices
		var choice_index = -1
		match event.as_text():
			"A", "J": choice_index = 0
			"S", "K": choice_index = 1
			"D", "L": choice_index = 2
			"F", ";": choice_index = 3
		
		if choice_index != -1:
			check_answer(choice_index)

func _on_choice_pressed(choice_index: int):
	if game_active:
		check_answer(choice_index)

func start_game():
	game_active = true
	current_player = 1
	ask_question()

func ask_question():
	if questions.size() == 0:
		# Reset questions if we've used them all
		questions = questions.duplicate()
	
	# Get random question
	var random_index = randi() % questions.size()
	current_question = questions[random_index]
	questions.remove_at(random_index)
	
	# Reset timer
	question_timer = max_question_time
	
	# Update question display
	$QuestionPanel/VBox/QuestionLabel.text = current_question.question
	
	# Update turn indicator
	update_turn_indicator()
	
	# Update choice buttons
	for i in range(4):
		var choice_button = get_node("QuestionPanel/VBox/Choice" + str(i + 1))
		choice_button.text = current_question.choices[i]
		choice_button.visible = true
		choice_button.disabled = false
		choice_button.modulate = Color(1, 1, 1)

func update_turn_indicator():
	var player_colors = {
		1: Color(1, 0, 0), # Red
		2: Color(0, 1, 0), # Green
		3: Color(0, 0, 1), # Blue
		4: Color(1, 1, 0), # Yellow
		5: Color(1, 0, 1), # Magenta
		6: Color(0, 1, 1), # Cyan
		7: Color(0.5, 0.5, 0.5), # Gray
		8: Color(0.5, 0, 0.5) # Purple
	}
	
	$QuestionPanel/TurnIndicator.text = "Player " + str(current_player) + "'s Turn"
	$QuestionPanel/TurnIndicator.modulate = player_colors[current_player]

func update_timer_display():
	var time_left = ceil(question_timer)
	$QuestionPanel/TimerLabel.text = str(time_left) + "s"
	
	# Change color based on time left
	if time_left <= 3:
		$QuestionPanel/TimerLabel.modulate = Color(1, 0, 0) # Red
	elif time_left <= 5:
		$QuestionPanel/TimerLabel.modulate = Color(1, 0.5, 0) # Orange
	else:
		$QuestionPanel/TimerLabel.modulate = Color(1, 1, 1) # White

func time_up():
	# Player loses their turn if time runs out
	var player = get_node("Players/Player" + str(current_player))
	player.slip()
	
	# Play time up sound
	$TimeUpSound.play()
	
	# Move to next player
	current_player = (current_player % active_players.size()) + 1
	
	# Ask next question after a short delay
	await get_tree().create_timer(1.0).timeout
	ask_question()

func check_answer(choice_index: int):
	# Get the current player
	var player = get_node("Players/Player" + str(current_player))
	if player.is_climbing or player.is_slipping:
		return
	
	# Check if the answer is correct
	if choice_index == current_question.correct_index:
		player.climb()
		# Visual feedback for correct answer
		get_node("QuestionPanel/VBox/Choice" + str(choice_index + 1)).modulate = Color(0, 1, 0)
		# Play correct sound
		$CorrectSound.play()
	else:
		player.slip()
		# Visual feedback for wrong answer
		get_node("QuestionPanel/VBox/Choice" + str(choice_index + 1)).modulate = Color(1, 0, 0)
		# Play wrong sound
		$WrongSound.play()
	
	# Disable all choice buttons temporarily
	for i in range(4):
		get_node("QuestionPanel/VBox/Choice" + str(i + 1)).disabled = true
	
	# Move to next player
	current_player = (current_player % active_players.size()) + 1
	
	# Ask next question after a short delay
	await get_tree().create_timer(1.0).timeout
	
	# Reset button colors
	for i in range(4):
		var choice_button = get_node("QuestionPanel/VBox/Choice" + str(i + 1))
		choice_button.modulate = Color(1, 1, 1)
	
	ask_question()

func player_won(player_id):
	game_active = false
	$QuestionPanel/VBox/QuestionLabel.text = "Player " + str(player_id) + " wins!"
	
	# Play win sound
	$WinSound.play()
	
	# Hide choice buttons
	for i in range(4):
		get_node("QuestionPanel/VBox/Choice" + str(i + 1)).visible = false
	
	# Restart game after 3 seconds
	await get_tree().create_timer(3.0).timeout
	reset_game()

func reset_game():
	# Reset all players to starting position
	for player in get_node("Players").get_children():
		player.position_y = 1000.0
		player.position.y = player.position_y
		player.is_climbing = false
		player.is_slipping = false
	
	# Reset active players
	active_players.clear()
	var player_count = get_node("/root/GameSettings").player_count
	for i in range(1, player_count + 1):
		active_players.append(i)
	
	# Start new game
	start_game()