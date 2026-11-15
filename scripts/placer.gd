extends Node2D

const SPRING_SCENE := preload("res://scenes/spring.tscn")

@export var max_springs := 8
@export var map_rect := Rect2(0, 0, 400, 300)   # 可放置的範圍（地圖大小），依需要調整
@export var angle_step := 15.0                  # 每次旋轉的角度
@export var pickup_radius := 35.0               # 右鍵收回的判定距離

var stock := 0
var angle := 0.0
var ghost: Area2D
var placed: Array[Node2D] = []
var slot_rects: Array[ColorRect] = []
var info_label: Label


func _ready() -> void:
	stock = max_springs
	_make_ghost()
	_make_hud()
	_refresh_hud()


func _make_ghost() -> void:
	ghost = SPRING_SCENE.instantiate() as Area2D
	add_child(ghost)
	ghost.monitoring = false      # 預覽用的跳板不會觸發彈跳
	ghost.monitorable = false
	ghost.z_index = 10


func _make_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.offset_bottom = -12
	box.add_theme_constant_override("separation", 6)
	layer.add_child(box)

	info_label = Label.new()
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 20)
	info_label.add_theme_color_override("font_outline_color", Color.BLACK)
	info_label.add_theme_constant_override("outline_size", 6)
	box.add_child(info_label)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	box.add_child(row)
	for i in max_springs:
		var slot := ColorRect.new()
		slot.custom_minimum_size = Vector2(34, 34)
		row.add_child(slot)
		slot_rects.append(slot)

	var hint := Label.new()
	hint.text = "左鍵 放置　右鍵 收回　滾輪 / Q E 旋轉　R 歸零"
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_outline_color", Color.BLACK)
	hint.add_theme_constant_override("outline_size", 5)
	hint.position = Vector2(12, 8)
	layer.add_child(hint)


func _refresh_hud() -> void:
	info_label.text = "跳板 %d / %d　　角度 %d°" % [stock, max_springs, int(angle)]
	for i in slot_rects.size():
		slot_rects[i].color = Color(1.0, 0.8, 0.15) if i < stock else Color(0.2, 0.2, 0.25, 0.8)


func _process(_delta: float) -> void:
	var pos := get_global_mouse_position()
	ghost.global_position = pos
	ghost.rotation_degrees = angle
	var can_place := stock > 0 and map_rect.has_point(pos)
	ghost.modulate = Color(1, 1, 1, 0.55) if can_place else Color(1, 0.3, 0.3, 0.45)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_place()
			MOUSE_BUTTON_RIGHT:
				_pick_up()
			MOUSE_BUTTON_WHEEL_UP:
				_rotate(angle_step)
			MOUSE_BUTTON_WHEEL_DOWN:
				_rotate(-angle_step)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E:
				_rotate(angle_step)
			KEY_Q:
				_rotate(-angle_step)
			KEY_R:
				angle = 0.0
				_refresh_hud()


func _rotate(delta_deg: float) -> void:
	angle = fposmod(angle + delta_deg, 360.0)
	_refresh_hud()


func _place() -> void:
	var pos := get_global_mouse_position()
	if stock <= 0 or not map_rect.has_point(pos):
		return
	var s := SPRING_SCENE.instantiate() as Node2D
	s.position = pos
	s.rotation_degrees = angle
	add_child(s)
	placed.append(s)
	stock -= 1
	_refresh_hud()


func _pick_up() -> void:
	var pos := get_global_mouse_position()
	var best: Node2D = null
	var best_d := pickup_radius
	for s in placed:
		var d := s.global_position.distance_to(pos)
		if d < best_d:
			best_d = d
			best = s
	if best == null:
		return
	placed.erase(best)
	best.queue_free()
	stock += 1
	_refresh_hud()
