extends Area2D

@export var spot_id       : String = "door"
@export var requires_item : String = "Key"
@export var target_scene  : String = "res://scenes/Level2/Level2.tscn"        # set in Inspector per level

@onready var sprite_closed : Sprite2D        = $SpriteClosed
@onready var sprite_open   : Sprite2D        = $SpriteOpen
@onready var anim_player   : AnimationPlayer = $AnimationPlayer

var _used        : bool = false
var _opened      : bool = false   # door is open, waiting for second E press
var _strings     : Dictionary = {}

func _ready() -> void:
	sprite_open.visible = false
	_strings = GameStrings.get_spot(spot_id)

func interact() -> void:
	# Second press: go to next scene
	if _opened:
		if target_scene != "":
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file(target_scene)
		return

	if _used:
		return

	if requires_item == "":
		_open()
		return

	if not Inventory.has_item(requires_item):
		return

	Inventory.remove_item(requires_item)
	_open()

func _open() -> void:
	_used = true
	if anim_player.has_animation("open"):
		anim_player.play("open")
		await anim_player.animation_finished
	else:
		sprite_closed.visible = false
		sprite_open.visible   = true
	_opened = true   # now ready for second press

func get_prompt_text() -> String:
	# Door is open — prompt to proceed
	if _opened:
		return _strings.get("prompt_next", "Press E to go to next level")

	if _used:
		return ""

	if requires_item == "":
		return _strings.get("prompt_open", "Press E to open")

	if Inventory.has_item(requires_item):
		var use_template : String = _strings.get("prompt_use", "Press E — use {item} on {spot}")
		return use_template.format({"item": requires_item, "spot": _strings.get("name", spot_id)})

	var locked_template : String = _strings.get("prompt_locked", "{spot} — requires {item}")
	return locked_template.format({"item": requires_item, "spot": _strings.get("name", spot_id)})
