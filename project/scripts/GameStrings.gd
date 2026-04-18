## Strings.gd
## AUTOLOAD SINGLETON — set up in Project > Project Settings > Autoload
## Name it exactly: Strings
##
## Loads all text from strings.json so you never hardcode
## text directly in scripts. Change text by editing the JSON only.
##
## Usage from any script:
##   Strings.get_spot("door")       → Dictionary of door strings
##   Strings.get_item("rusty_key")  → Dictionary of item strings
##   Strings.get("some_key")        → any top-level string

extends Node

var _data : Dictionary = {}

func _ready() -> void:
	_load()

func _load() -> void:
	var path = "res://data/strings.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Strings: could not open " + path)
		return
	var text   = file.get_as_text()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("Strings: failed to parse JSON")
		return
	_data = parsed
	print("Strings loaded OK")

# Get a top-level string by key
func fetch(key: String, fallback: String = "") -> String:
	return _data.get(key, fallback)   # for simple string values

func get_section(key: String) -> Dictionary:
	return _data.get(key, {})         # for sections like "ui", "spots", "items"

func get_spot(spot_id: String) -> Dictionary:
	return get_section("spots").get(spot_id, {})

func get_item(item_id: String) -> Dictionary:
	return get_section("items").get(item_id, {})
