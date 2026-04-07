## Inventory.gd
## Autoload singleton. Now backed by the C++ InventorySystem module.
extends Node

signal inventory_changed

# ── C++ backend ───────────────────────────────────────────
var _cpp : InventorySystem = InventorySystem.new()

# ── Add an item ───────────────────────────────────────────
# item must have "id", "name", and optionally "color" (as Color)
func add_item(item: Dictionary) -> void:
	# C++ stores id/name/quantity — color is GDScript-side only
	var cpp_item := { "id": item.get("id", item.get("name", "")), "name": item.get("name", "") }
	var added := _cpp.add_item(cpp_item)
	if added:
		emit_signal("inventory_changed")
		print("[Inventory] Added: ", item.get("name", "?"))
	else:
		print("[Inventory] Full or invalid item: ", item)

# ── Remove an item by name ────────────────────────────────
func remove_item(item_name: String) -> void:
	var removed := _cpp.remove_item(item_name)
	if removed:
		emit_signal("inventory_changed")
		print("[Inventory] Removed: ", item_name)

# ── Check if an item is in inventory ─────────────────────
func has_item(item_name: String) -> bool:
	return _cpp.has_item(item_name)

# ── Get all items (used by UI) ────────────────────────────
# Returns Array of Dictionaries with "id", "name", "quantity"
func get_items() -> Array:
	return _cpp.get_all_items()

# ── Get item count ────────────────────────────────────────
func count() -> int:
	return _cpp.get_item_count()

# ── Clear everything ──────────────────────────────────────
func clear() -> void:
	_cpp.clear()
	emit_signal("inventory_changed")

# ── Max slots ─────────────────────────────────────────────
func get_max_slots() -> int:
	return _cpp.get_max_slots()

func _ready() -> void:
	print("[Inventory] C++ backend ready. Max slots: ", _cpp.get_max_slots())
