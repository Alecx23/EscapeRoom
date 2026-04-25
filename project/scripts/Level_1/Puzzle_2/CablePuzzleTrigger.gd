extends Area2D

# ── Exports ────────────────────────────────────────────────────────────────────
@export var spot_id       : String = "cable_panel"
@export var target_scene  : String = "res://scenes/Level1/puzzles/cable_puzzle/Cablepuzzle.tscn"

var _strings : Dictionary = {}

# ── Lifecycle ──────────────────────────────────────────────────────────────────
func _ready() -> void:
	if has_node("/root/GameStrings"):
		_strings = GameStrings.get_spot(spot_id)

# ── Interaction ────────────────────────────────────────────────────────────────
func interact() -> void:
	if target_scene != "":
		# Switch the whole screen to the puzzle
		get_tree().change_scene_to_file(target_scene)

func get_prompt_text() -> String:
	return _strings.get("prompt_open", "Press E to route cables")
