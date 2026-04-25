extends Node

# ── Puzzle completion flags ────────────────────────────────────────────────
var pipe_puzzle_solved : bool = false
var cable_puzzle_solved : bool = false  # Added this for your new puzzle

# ── Counter ───────────────────────────────────────────────────────────────
var puzzles_solved : int = 0

# ── The Function (This fixes the crash) ──────────────────────────────────
func puzzle_solved(puzzle_id: String) -> void:
	# 1. Check which puzzle was just finished
	match puzzle_id:
		"pipe_puzzle":
			if not pipe_puzzle_solved:
				pipe_puzzle_solved = true
				puzzles_solved += 1
				print("Pipe puzzle completed!")
				
		"cable_puzzle":
			if not cable_puzzle_solved:
				cable_puzzle_solved = true
				puzzles_solved += 1
				print("Cable puzzle completed!")

	# 2. Optional: Check if ALL puzzles are done
	print("Total puzzles solved: ", puzzles_solved)
