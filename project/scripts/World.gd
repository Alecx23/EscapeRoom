extends Node2D

@export var world_width  : float = 3000.0
@export var world_height : float = 3000.0

@onready var player = $Player
@onready var items_node  : Node2D = $Items
@onready var spots_node  : Node2D = $UseSpots

func _ready() -> void:
	_create_borders()

func _create_borders() -> void:
	var walls := [
		# [position,          half-width,        half-height]
		[Vector2(world_width / 2, -10),            world_width / 2, 10],   # top
		[Vector2(world_width / 2, world_height + 10), world_width / 2, 10], # bottom
		[Vector2(-10, world_height / 2),           10, world_height / 2],  # left
		[Vector2(world_width + 10, world_height / 2), 10, world_height / 2] # right
	]
	for w in walls:
		var body  := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect  := RectangleShape2D.new()
		rect.size = Vector2(w[1] * 2, w[2] * 2)
		shape.shape    = rect
		body.position  = w[0]
		body.add_child(shape)
		add_child(body)


func _process(_delta: float) -> void:
	pass
