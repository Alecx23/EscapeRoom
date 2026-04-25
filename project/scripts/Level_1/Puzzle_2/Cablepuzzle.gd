extends Control

# ── Exports ────────────────────────────────────────────────────────────────────
@export var max_wrong_attempts: int = 5
@export var return_scene_path: String = "res://scenes/Level1/Level1.tscn"

# ── Constants ──────────────────────────────────────────────────────────────────
const CABLE_COLORS := {
	"red":    Color(0.85, 0.15, 0.10),
	"yellow": Color(0.95, 0.80, 0.05),
	"blue":   Color(0.10, 0.35, 0.90),
	"green":  Color(0.30, 0.75, 0.10),
}
const CABLE_TEXTURES := {
	"red":    "res://assets/Objects/lvl1/Cable Puzzle/Red Cable.png",
	"yellow": "res://assets/Objects/lvl1/Cable Puzzle/Yellow Cable.png",
	"blue":   "res://assets/Objects/lvl1/Cable Puzzle/Blue Cable.png",
	"green":  "res://assets/Objects/lvl1/Cable Puzzle/Green Cable.png",
}
const SNAP_RADIUS    : float = 45.0
const WIRE_WIDTH     : float = 10.0 # Thicker wires look better with your art

# ── Node refs ──────────────────────────────────────────────────────────────────
@onready var left_panel    : Control  = $Background/VBox/PanelRow/LeftPanel
@onready var right_panel   : Control  = $Background/VBox/PanelRow/RightPanel
@onready var wire_layer    : Control  = $Background/VBox/PanelRow/WireLayer
@onready var solved_banner : Control  = $SolvedBanner
@onready var attempts_label: Label    = $Background/VBox/AttemptsLabel
@onready var close_btn     : Button   = $Background/VBox/TopBar/CloseButton

# ── State ──────────────────────────────────────────────────────────────────────
var _cable_order  : Array[String] = ["red", "yellow", "blue", "green"]
var _right_order  : Array[String] = []
var _connections  : Dictionary    = {}
var _wrong_count  : int           = 0

# Drag state
var _dragging        : bool    = false
var _drag_color      : String  = ""
var _drag_line       : Line2D  = null
var _drag_origin     : Vector2 = Vector2.ZERO

# Node/Slot maps
var _left_nodes      : Dictionary = {} # color -> TextureRect
var _right_slots     : Dictionary = {} # color -> Marker/Control node

# ── Lifecycle ──────────────────────────────────────────────────────────────────
func _ready() -> void:
	solved_banner.hide()
	close_btn.pressed.connect(_close)
	_reset()

func _close() -> void:
	get_tree().change_scene_to_file(return_scene_path)

func _reset() -> void:
	_connections.clear()
	_wrong_count = 0
	_dragging    = false
	
	# Clear old wires and spawned textures
	for child in wire_layer.get_children(): child.queue_free()
	# Only remove TextureRects, keep your manual Slot/Marker nodes!
	for child in left_panel.get_children():
		if child is TextureRect: child.queue_free()
	for child in right_panel.get_children():
		if child is TextureRect: child.queue_free()
	
	_left_nodes.clear()
	_right_slots.clear()

	_right_order = _cable_order.duplicate()
	_right_order.shuffle()
	
	_build_panels()
	_update_attempts_label()

func _build_panels() -> void:
	# 1. Get your hand-placed markers
	var l_slots = left_panel.get_children().filter(func(node): return not node is TextureRect)
	var r_slots = right_panel.get_children().filter(func(node): return not node is TextureRect)
	
	var n = _cable_order.size()
	
	# 2. Assign Left Cables to Slots 1-4
	for i in n:
		var color_name = _cable_order[i]
		var cable = _make_cable_node(color_name, true)
		left_panel.add_child(cable)
		
		# Snap cable tip to the slot position
		# Tip is at (width, height/2), so we offset by that
		cable.position = l_slots[i].position - Vector2(cable.size.x, cable.size.y * 0.5)
		
		_left_nodes[color_name] = cable
		cable.gui_input.connect(_on_left_input.bind(color_name))

	# 3. Assign Right Cables (Shuffled) to Slots 1-4
	for i in n:
		var color_name = _right_order[i]
		var cable = _make_cable_node(color_name, false)
		right_panel.add_child(cable)
		
		# Snap flipped cable tip to the slot position
		# Flipped tip is at (0, height/2)
		cable.position = r_slots[i].position - Vector2(0, cable.size.y * 0.5)
		
		# Save this slot so we know where this color is supposed to snap to later
		_right_slots[color_name] = r_slots[i]

func _make_cable_node(color_name: String, face_right: bool) -> TextureRect:
	var tex_rect = TextureRect.new()
	tex_rect.texture = load(CABLE_TEXTURES[color_name])
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Adjust these dimensions to match your PNG size
	tex_rect.custom_minimum_size = Vector2(140, 32)
	tex_rect.size = Vector2(140, 32)
	
	if not face_right:
		tex_rect.flip_h = true
	return tex_rect

# ── Input & Connections ───────────────────────────────────────────────────────
func _on_left_input(event: InputEvent, color_name: String) -> void:
	if _connections.get(color_name, false): return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drag(color_name)

func _start_drag(color_name: String) -> void:
	_dragging = true
	_drag_color = color_name
	
	_drag_line = Line2D.new()
	_drag_line.width = WIRE_WIDTH
	_drag_line.default_color = CABLE_COLORS[color_name]
	_drag_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_drag_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	wire_layer.add_child(_drag_line)
	
	var cable = _left_nodes[color_name]
	var tip_global = cable.global_position + Vector2(cable.size.x, cable.size.y * 0.5)
	
	_drag_origin = wire_layer.get_global_transform().affine_inverse() * tip_global
	_drag_line.add_point(_drag_origin)
	_drag_line.add_point(_drag_origin)

func _input(event: InputEvent) -> void:
	if not _dragging: return
	
	if event is InputEventMouseMotion:
		var local_mouse = wire_layer.get_global_transform().affine_inverse() * event.global_position
		_drag_line.set_point_position(1, local_mouse)
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_try_connect(event.global_position)

func _try_connect(global_drop: Vector2) -> void:
	_dragging = false
	var best_color = ""
	var best_dist = SNAP_RADIUS
	
	# Find which slot the mouse was closest to
	for color_name in _right_slots:
		if _connections.get(color_name, false): continue
		var slot_node = _right_slots[color_name]
		var dist = global_drop.distance_to(slot_node.global_position)
		if dist < best_dist:
			best_dist = dist
			best_color = color_name

	if best_color == _drag_color:
		_on_correct_match(_drag_color)
	else:
		if _drag_line: _drag_line.queue_free()
		# Add optional wrong match logic here (like reducing attempts)

func _on_correct_match(color_name: String) -> void:
	_connections[color_name] = true
	var target_slot = _right_slots[color_name]
	
	# Snap the line to the global position of your manual marker
	var end_local = wire_layer.get_global_transform().affine_inverse() * target_slot.global_position
	_drag_line.set_point_position(1, end_local)
	
	_left_nodes[color_name].modulate.a = 0.5
	# Find the TextureRect on the right side to dim it too
	for child in right_panel.get_children():
		if child is TextureRect and child.texture == load(CABLE_TEXTURES[color_name]):
			child.modulate.a = 0.5

	if _connections.size() == _cable_order.size():
		_on_puzzle_solved()

func _update_attempts_label() -> void:
	attempts_label.text = "Attempts remaining: %d" % (max_wrong_attempts - _wrong_count)

func _on_puzzle_solved() -> void:
	solved_banner.show()
	if has_node("/root/PuzzleProgress"):
		get_node("/root/PuzzleProgress").puzzle_solved("cable_puzzle")
	await get_tree().create_timer(2.0).timeout
	_close()
