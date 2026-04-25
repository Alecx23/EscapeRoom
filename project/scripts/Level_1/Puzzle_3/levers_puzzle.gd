extends Node2D

const SAVE_KEY = "levers_puzzle_solved"

@onready var puzzle_completed = $CanvasLayer
@onready var switch_box = $SwitchBox

func _ready() -> void:
	puzzle_completed.hide()
	
	var d = GameSave.get_game_data()
	var puzzle = d.get("puzzles", {})
	
	if puzzle.get("levers_puzzle", false):
		_go_back()
		return
	
	switch_box.puzzle_solved.connect(_on_puzzle_solved)

func _input(event)->void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_go_back()

func _on_puzzle_solved()->void:
	var d = GameSave.get_game_data()
	var puzzles = d.get("puzzles", {})
	
	puzzles["levers_puzzle"] = true
	d["puzzles"] = puzzles
	GameSave.save_game()
	
	for lever in switch_box.levers:
		lever.set_process_input(false)
	
	puzzle_completed.show()
	await get_tree().create_timer(2.0).timeout
	_go_back()

func _go_back()->void:
	get_tree().change_scene_to_file("res://scenes/Level1/Level1.tscn")
