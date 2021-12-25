tool
extends Node

export (NodePath) var static_body_path
export var swap : bool = false
export var do_align : bool = false setget run_align
export var do_create : bool = false setget run_create

func run_align(pressed):
	if Engine.editor_hint and pressed:
		if !static_body_path.is_empty():
			var static_body : StaticBody2D = get_node(static_body_path)
			var polygon : Polygon2D = static_body.get_node("Polygon2D")
			var collision_polygon : CollisionPolygon2D = static_body.get_node("CollisionPolygon2D")
			if swap:
				polygon.polygon = collision_polygon.polygon
			else:
				collision_polygon.polygon = polygon.polygon
		else:
			print("PolygonManager: please set static_body_path")

func run_create(pressed):
	if Engine.editor_hint and pressed:
		var scene = get_tree().edited_scene_root
		
		var static_body = StaticBody2D.new()
		var collision_polygon = CollisionPolygon2D.new()
		var polygon = Polygon2D.new()
		
		static_body.add_child(polygon)
		static_body.add_child(collision_polygon)
		scene.add_child(static_body)
		
		static_body.owner = scene
		collision_polygon.owner = scene
		polygon.owner = scene
