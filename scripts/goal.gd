extends Area2D
signal reached

func _ready() -> void:
	z_index = 2
	var spr := Sprite2D.new()
	spr.texture = preload("res://assets/flags/end_flag.png")
	spr.scale = Vector2(0.08, 0.08)
	spr.offset = Vector2(100, -spr.texture.get_height() / 2.0)
	add_child(spr)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 40)
	cs.shape = shape
	cs.position = Vector2(8, -20)
	add_child(cs)

	var lab := Label.new()
	lab.text = "End"
	lab.add_theme_font_size_override("font_size", 10)
	lab.add_theme_color_override("font_outline_color", Color.BLACK)
	lab.add_theme_constant_override("outline_size", 3)
	lab.position = Vector2(-10, -56)
	add_child(lab)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		reached.emit()
