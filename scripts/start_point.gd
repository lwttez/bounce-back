extends Node2D

func _ready() -> void:
	z_index = 2
	var spr := Sprite2D.new()
	spr.texture = preload("res://assets/flags/start_flag.png")
	spr.scale = Vector2(0.08, 0.08)
	spr.offset = Vector2(100, -spr.texture.get_height() / 2.0)
	add_child(spr)
