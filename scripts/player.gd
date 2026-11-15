extends CharacterBody2D
## 簡單的 2D 玩家：A/D 或 左右鍵 移動，W / 上 / 空白鍵 跳躍。
## 碰到尖刺會呼叫 die()，回到起點。

signal died

@export var speed := 110.0
@export var jump_speed := 270.0
@export var gravity := 700.0
@export var ground_accel := 900.0
@export var air_accel := 450.0

var start_position := Vector2.ZERO   # 起點（腳底位置）
var facing := 1.0
var flash := 0.0


func _ready() -> void:
	z_index = 8
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(14, 22)
	cs.shape = shape
	add_child(cs)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	var dir := 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir += 1.0
	if dir != 0.0:
		facing = dir
	var accel := ground_accel if is_on_floor() else air_accel
	velocity.x = move_toward(velocity.x, dir * speed, accel * delta)
	var want_jump := Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_SPACE)
	if want_jump and is_on_floor():
		velocity.y = -jump_speed
	move_and_slide()
	if flash > 0.0:
		flash = maxf(flash - delta, 0.0)
	queue_redraw()


func die() -> void:
	died.emit()
	call_deferred("_respawn")


func _respawn() -> void:
	global_position = start_position + Vector2(0, -11)
	velocity = Vector2.ZERO
	flash = 0.4


func _draw() -> void:
	var body_color := Color(1.0, 0.3, 0.3) if flash > 0.0 else Color(0.25, 0.6, 1.0)
	draw_rect(Rect2(-7, -11, 14, 22), body_color)
	draw_rect(Rect2(-7, -11, 14, 22), Color(0.05, 0.1, 0.2), false, 1.0)
	var ex := 1.5 * facing
	draw_rect(Rect2(-4 + ex, -6, 3, 4), Color.WHITE)
	draw_rect(Rect2(1 + ex, -6, 3, 4), Color.WHITE)
