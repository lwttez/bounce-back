extends Area2D
signal reached

func _ready() -> void:
	z_index = 2
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 40)
	cs.shape = shape
	cs.position = Vector2(0, -20)
	add_child(cs)
	var lab := Label.new()
	lab.text = "終點"
	lab.add_theme_font_size_override("font_size", 10)
	lab.add_theme_color_override("font_outline_color", Color.BLACK)
	lab.add_theme_constant_override("outline_size", 3)
	lab.position = Vector2(-10, -56)
	add_child(lab)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		reached.emit()

func _draw() -> void:
	draw_rect(Rect2(-16, -3, 32, 3), Color(1.0, 0.8, 0.15))
	draw_line(Vector2(6, 0), Vector2(6, -40), Color(0.9, 0.9, 0.9), 2.0)
	for r in 3:
		for c in 4:
			var col := Color.WHITE if (r + c) % 2 == 0 else Color.BLACK
			draw_rect(Rect2(6 - 16 + c * 4, -40 + r * 4, 4, 4), col)
