extends SaveManager

func initiate_full_save() -> void:
	
	var nodes = get_tree().get_nodes_in_group("player")
	var p = null
	
	for node in nodes:
		if node is CharacterBody2D:
			p = node
			break
	
	print("--- DEBUG SAVE ---")
	if p:
		print("Nodul CORECT găsit: ", p.name, " la poziția: ", p.global_position)
		
		var d = game_data
		d["player_x"] = p.global_position.x
		d["player_y"] = p.global_position.y
		d["level_name"] = get_tree().current_scene.scene_file_path
		
		var items = Inventory.get_items()
		var items_to_save = []
		
		for item in items:
			var item_copy = item.duplicate()
			if item_copy.has("texture") and item_copy["texture"] is Texture2D:
				item_copy["texture"] = item_copy["texture"].resource_path
			items_to_save.append(item_copy)
			
		d["inventory"] = items_to_save
		
		# ── Puzzle progress ───────────────────────────────────────────────
		d["pipe_puzzle_solved"] = PuzzleProgress.pipe_puzzle_solved
		d["puzzles_solved"]     = PuzzleProgress.puzzles_solved
		# Add more puzzle flags here as you build them:
		# d["wire_puzzle_solved"] = PuzzleProgress.wire_puzzle_solved
		# d["safe_puzzle_solved"] = PuzzleProgress.safe_puzzle_solved
		# ─────────────────────────────────────────────────────────────────
		
		game_data = d
		save_game()
		print("[SAVE] Succes!")
	else:
		print("!!! EROARE: Nu am găsit niciun CharacterBody2D în grupul 'player'!")

	save_game()
	print("--- SAVE FINISHED ---")

	
func load_game_and_apply() -> void:
	load_game()
	
	if game_data.is_empty():
		print("[LOAD] EROARE: Nu am găsit fișierul de salvare!")
		return

	var saved_scene = game_data.get("level_name", "")
	if saved_scene != "" and saved_scene != get_tree().current_scene.scene_file_path:
		print("[LOAD] Schimb scena către: ", saved_scene)
		get_tree().change_scene_to_file(saved_scene)
		await get_tree().node_added 
		await get_tree().process_frame
		await get_tree().process_frame

	var nodes = get_tree().get_nodes_in_group("player")
	var p = null
	
	for node in nodes:
		if node is CharacterBody2D:
			p = node
			break

	if p:
		var pos_x = game_data.get("player_x", p.global_position.x)
		var pos_y = game_data.get("player_y", p.global_position.y)
		p.global_position = Vector2(pos_x, pos_y)
		print("[LOAD] Succes! Player teleportat la: ", p.global_position)
		
		var loaded_items = game_data.get("inventory", [])
		var fixed_items = []
		
		for item_data in loaded_items:
			var item_copy = item_data.duplicate()
			if item_copy.has("texture") and item_copy["texture"] is String:
				var path = item_copy["texture"]
				if path.begins_with("res:/") and not path.begins_with("res://"):
					path = path.replace("res:/", "res://")
				if FileAccess.file_exists(path):
					item_copy["texture"] = load(path)
				else:
					print("[LOAD] the image has no path")
			fixed_items.append(item_copy)

		# ── Puzzle progress ───────────────────────────────────────────────
		PuzzleProgress.pipe_puzzle_solved = game_data.get("pipe_puzzle_solved", false)
		PuzzleProgress.puzzles_solved     = game_data.get("puzzles_solved", 0)
		# Add more puzzle flags here as you build them:
		# PuzzleProgress.wire_puzzle_solved = game_data.get("wire_puzzle_solved", false)
		# PuzzleProgress.safe_puzzle_solved = game_data.get("safe_puzzle_solved", false)
		print("[LOAD] Puzzle progress restaurat. Solved: ", PuzzleProgress.puzzles_solved, "/3")
		# ─────────────────────────────────────────────────────────────────

	else:
		print("[LOAD] EROARE: Scena s-a încărcat, dar nu am găsit nodul 'player'!")
