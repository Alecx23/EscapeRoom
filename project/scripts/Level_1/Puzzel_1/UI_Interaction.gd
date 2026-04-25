extends Area2D

@export var spot_id       : String = "computer"
@export var target_scene  : String = "res://scenes/Level1/puzzles/pipe_puzzle/PipePuzzle.tscn" # Drag your PipePuzzle.tscn here

var _strings : Dictionary = {}

func _ready() -> void:
	# Safely get strings for the prompt
	if has_node("/root/GameStrings"):
		_strings = GameStrings.get_spot(spot_id)

func interact() -> void:
	if target_scene != "":
		# Switches the whole screen to the puzzle
		get_tree().change_scene_to_file(target_scene)

func get_prompt_text() -> String:
	return _strings.get("prompt_open", "Press E to fix pipes")
