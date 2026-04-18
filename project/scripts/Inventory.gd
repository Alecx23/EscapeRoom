## Inventory.gd
## Autoload singleton backed by the C++ InventorySystem.
extends Node

signal inventory_changed

# ── C++ backend ───────────────────────────────────────────
var _cpp : InventorySystem = InventorySystem.new()

func _ready() -> void:
	print("[Inventory] C++ backend ready. Max slots: ", _cpp.get_max_slots())

# ── Add an item ───────────────────────────────────────────
func add_item(item: Dictionary) -> void:
	if not item.has("id"):
		item["id"] = item.get("name", "")
	var added := _cpp.add_item(item)
	if added:
		emit_signal("inventory_changed")
		print("[Inventory] Added: ", item.get("name", "?"))
	else:
		print("[Inventory] Full or invalid: ", item.get("name", "?"))

# ── Remove an item by id ──────────────────────────────────
func remove_item(item_id: String) -> void:
	var removed := _cpp.remove_item(item_id)
	if removed:
		emit_signal("inventory_changed")
		print("[Inventory] Removed: ", item_id)

# ── Check if an item exists ───────────────────────────────
func has_item(item_id: String) -> bool:
	return _cpp.has_item(item_id)

# ── Get all items (used by UI) ────────────────────────────
func get_items() -> Array:
	return _cpp.get_all_items()

# ── Get a single item by id ───────────────────────────────
func get_item(item_id: String) -> Dictionary:
	return _cpp.get_item(item_id)

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
