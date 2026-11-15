extends Node2D

func _ready() -> void:
	z_index = 2
	var lab := Label.new()
	lab.text = "Start"
	lab.add_theme_font_size_override("font_size", 10)
	lab.add_theme_color_override("font_outline_color", Color.BLACK)
	lab.add_theme_constant_override("outline_size", 3)
	lab.position = Vector2(-10, -44)
	add_child(lab)

func _draw() -> void:
	draw_rect(Rect2(-16, -3, 32, 3), Color(0.2, 0.85, 0.35))
	draw_line(Vector2(-10, 0), Vector2(-10, -30), Color(0.9, 0.9, 0.9), 2.0)
	draw_colored_polygon(PackedVector2Array([Vector2(-10, -30), Vector2(6, -25), Vector2(-10, -20)]), Color(0.2, 0.85, 0.35))
