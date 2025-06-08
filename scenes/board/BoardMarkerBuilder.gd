@tool                       # ← run in editor when scene opens
extends Node2D

@export var cols := 7
@export var rows := 6
@export var gap  := 0

@onready var board_sprite : Sprite2D = $BoardImage
@onready var markers      : Node2D  = $TileMarkers
