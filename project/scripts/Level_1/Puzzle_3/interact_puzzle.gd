extends Area2D

var player_inside = false
@onready var e_label = $ELabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body)->void:
	if body.is_in_group("player"):
		
		var d = GameSave.get_game_data()
		var puzzles = d.get("puzzles", {})
		if puzzles.get("levers_puzzle", false):
			return
			
		player_inside = true
		e_label.show()

func _on_body_exited(body)->void:
	if body.is_in_group("player"):
		player_inside = false
		e_label.hide()

func _input(event)->void:
	if player_inside and event is InputEventKey:
		if event.pressed and event.keycode == KEY_E:
			open_puzzle()

func open_puzzle()->void:
	e_label.hide()
	get_tree().change_scene_to_file("res://scenes/Level1/puzzles/puzzle_3/Levers_puzzle.tscn")
