## PickableItem.gd
## Attach to: PickableItem (Area2D)
##
## Scene structure:
##   PickableItem (Area2D)    ← this script goes here
##   ├── Sprite2D             ← your item image (key.png, etc.)
##   └── CollisionShape2D     ← CircleShape2D, radius ~20
##
## HOW TO ADD A NEW ITEM:
##   1. Duplicate the PickableItem scene
##   2. Swap the Sprite2D texture to your item's PNG
##   3. The item name and icon are read automatically from the texture
##   4. Place it anywhere in the World scene under the Items node
extends Area2D

@export var item_name  : String    = "Item"
@export var item_color : Color     = Color.GOLD
@export var item_icon  : Texture2D = null

var _picked : bool = false

func _ready() -> void:
	# Auto-set item_name from sprite texture filename if still default
	if item_name == "Item":
		var sprite = get_node_or_null("Sprite2D")
		if sprite and sprite.texture:
			var path = sprite.texture.resource_path
			item_name = path.get_file().get_basename().capitalize()

func interact() -> void:
	if _picked:
		return
	_picked = true

	# Auto-read icon from Sprite2D if not manually set
	var icon = item_icon
	if icon == null:
		var sprite = get_node_or_null("Sprite2D")
		if sprite and sprite.texture:
			icon = sprite.texture

	Inventory.add_item({
		"id":    item_name,
		"name":  item_name,
		"color": item_color,
		"icon":  icon,
	})
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)

func get_prompt_text() -> String:
	if _picked:
		return ""
	return "Press E — pick up \"%s\"" % item_name
