extends SaveManager

func initiate_full_save() -> void:
	var nodes = get_tree().get_nodes_in_group("player")
	var p = null
	
	# Căutăm printre cele 2 noduri pe cel care este corpul personajului
	for node in nodes:
		if node is CharacterBody2D: # Verificăm dacă e nodul cu fizică (cel care se mișcă)
			p = node
			break # L-am găsit, nu mai căutăm
	
	print("--- DEBUG SAVE ---")
	if p:
		print("Nodul CORECT găsit: ", p.name, " la poziția: ", p.global_position)
		
		var d = game_data
		d["player_x"] = p.global_position.x
		d["player_y"] = p.global_position.y
		d["level_name"] = get_tree().current_scene.scene_file_path
		d["inventory"] = Inventory.get_all_items()
		
		game_data = d
		save_game()
		print("[SAVE] Succes!")
	else:
		print("!!! EROARE: Nu am găsit niciun CharacterBody2D în grupul 'player'!")

	# 3. Scriem pe disc
	save_game()
	print("--- SAVE FINISHED ---")
	
func load_game_and_apply() -> void:
	# 1. Citim datele din C++
	load_game()
	
	if game_data.is_empty():
		print("[LOAD] EROARE: Nu am găsit fișierul de salvare!")
		return

	# 2. Schimbăm scena (dacă e cazul)
	var saved_scene = game_data.get("level_name", "")
	if saved_scene != "" and saved_scene != get_tree().current_scene.scene_file_path:
		print("[LOAD] Schimb scena către: ", saved_scene)
		get_tree().change_scene_to_file(saved_scene)
		
		# ASTEPTĂM ca scena să se încarce complet
		await get_tree().node_added 
		await get_tree().process_frame
		await get_tree().process_frame # Două frame-uri pentru siguranță maximă

	# 3. Căutăm Player-ul (folosim aceeași logică ca la Save)
	var nodes = get_tree().get_nodes_in_group("player")
	var p = null
	
	for node in nodes:
		if node is CharacterBody2D:
			p = node
			break

	if p:
		# 4. Aplicăm poziția
		var pos_x = game_data.get("player_x", p.global_position.x)
		var pos_y = game_data.get("player_y", p.global_position.y)
		
		p.global_position = Vector2(pos_x, pos_y)
		print("[LOAD] Succes! Player teleportat la: ", p.global_position)
		
		# 5. Restaurăm Inventarul
		var saved_items = game_data.get("inventory", [])
		Inventory.set_all_items(saved_items)
		Inventory.inventory_changed.emit()
	else:
		print("[LOAD] EROARE: Scena s-a încărcat, dar nu am găsit nodul 'player'!")
