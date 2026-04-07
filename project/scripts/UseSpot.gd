## UseSpot.gd
## Attach to: UseSpot (Area2D)
##
## Scene structure:
##   UseSpot (Area2D)
##   ├── SpriteClosed (Sprite2D)
##   ├── SpriteOpen   (Sprite2D)   — visible: false by default
##   ├── CollisionShape2D
##   └── AnimationPlayer           — has animation "open"

extends Area2D

# ── Inspector properties ──────────────────────────────────
@export var spot_id       : String = "door"    # key used in strings.json
@export var requires_item : String = ""        # must match PickableItem item_name

# ── Scene children ────────────────────────────────────────
@onready var sprite_closed : Sprite2D        = $SpriteClosed
@onready var sprite_open   : Sprite2D        = $SpriteOpen
@onready var anim_player   : AnimationPlayer = $AnimationPlayer

# ── Internal ──────────────────────────────────────────────
var _used    : bool = false
var _strings : Dictionary = {}

# ── Ready ─────────────────────────────────────────────────
func _ready() -> void:
	sprite_open.visible = false
	_strings = GameStrings.get_spot(spot_id)
# ── Called by Player when E is pressed ───────────────────
func interact() -> void:
	if _used:
		return

	# If no item required, open directly
	if requires_item == "":
		_open()
		return

	# Check inventory for required item
	if not Inventory.has_item(requires_item):
		return

	Inventory.remove_item(requires_item)
	_open()

func _open() -> void:
	_used = true
	if anim_player.has_animation("open"):
		anim_player.play("open")
	else:
		sprite_closed.visible = false
		sprite_open.visible   = true

# ── Prompt text ───────────────────────────────────────────
func get_prompt_text() -> String:
	if _used:
		return ""

	if requires_item == "":
		return _strings.get("prompt_open", "Press E to open")

	if Inventory.has_item(requires_item):
		var use_template : String = _strings.get("prompt_use", "Press E — use {item} on {spot}")
		return use_template.format({"item": requires_item, "spot": _strings.get("name", spot_id)})

	var locked_template : String = _strings.get("prompt_locked", "{spot} — requires {item}")
	return locked_template.format({"item": requires_item, "spot": _strings.get("name", spot_id)})
