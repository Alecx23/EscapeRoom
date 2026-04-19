extends Control

@onready var start_button: Button = $MainMenu/Start_Button
@onready var main_menu = $MainMenu
@onready var start_menu = $StarMenu

func _ready() -> void:
	main_menu.visible = true
	start_menu.visible = false
func _on_start_button_pressed() -> void:
	main_menu.hide()
	start_menu.show()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
	

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_new_game_button_pressed() -> void:
	Inventory.clear_inventory()
	
	GameSave.game_data = {}
	var starting_level = "res://scenes/Level1/Level1.tscn"
	
	if FileAccess.file_exists(starting_level):
		get_tree().change_scene_to_file(starting_level)
	else:
		print("Error: Didn't find the starting scene")


func _on_load_save_button_pressed() -> void:
	GameSave.load_game_and_apply()


func _on_back_button_pressed() -> void:
	start_menu.hide()
	main_menu.show()
