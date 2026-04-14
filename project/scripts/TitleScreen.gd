extends Control

@onready var start_button: Button = $VBoxContainer/Start_Button

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/World.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
