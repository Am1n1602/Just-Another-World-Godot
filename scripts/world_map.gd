extends Node2D

@onready var dark_world: Node = $"Dark-World"
@onready var light_world: Node = $"Light-World"

var using_dark_world: bool = false

func _ready() -> void:
	# Start in light world
	set_world_state(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Switch_World"):
		toggle_world()

func toggle_world() -> void:
	using_dark_world = !using_dark_world
	set_world_state(using_dark_world)

func set_world_state(dark_active: bool) -> void:
	# Dark world enabled, Light world disabled
	_set_children_state(dark_world, dark_active)
	_set_children_state(light_world, not dark_active)

func _set_children_state(world: Node, enabled: bool) -> void:
	world.visible = enabled

	# If the world itself is a TileMapLayer → toggle collisions
	if world is TileMapLayer:
		world.collision_enabled = enabled

	for child in world.get_children():
		_apply_state_recursive(child, enabled)

func _apply_state_recursive(node: Node, enabled: bool) -> void:
	# Visibility
	if node is CanvasItem:
		node.visible = enabled

	# TileMapLayer
	if node is TileMapLayer:
		node.collision_enabled = enabled

	# Collision shapes
	elif node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = not enabled

	# Physics bodies
	elif node is CollisionObject2D:
		if enabled:
			node.collision_layer = node.get_meta("orig_layer") if node.has_meta("orig_layer") else node.collision_layer
			node.collision_mask = node.get_meta("orig_mask") if node.has_meta("orig_mask") else node.collision_mask
		else:
			if not node.has_meta("orig_layer"):
				node.set_meta("orig_layer", node.collision_layer)
			if not node.has_meta("orig_mask"):
				node.set_meta("orig_mask", node.collision_mask)
			node.collision_layer = 0
			node.collision_mask = 0

	# Recurse into children
	for child in node.get_children():
		_apply_state_recursive(child, enabled)
