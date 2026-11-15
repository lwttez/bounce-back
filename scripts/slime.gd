extends CharacterBody2D
## 史萊姆玩家。A/D 或 ←→ 移動，W / ↑ / 空白鍵 彈跳。
## 碰到尖刺會呼叫 die()，回到起點。

signal died

@export var speed: float = 110
@export var jump_velocity: float = -400
@export var foot_offset: float = 5.0     # 腳底到中心的距離（用來對齊起點）

var start_position := Vector2.ZERO
var lives = 3
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	_ensure_action("bounce", [KEY_SPACE, KEY_W, KEY_UP])
	_ensure_action("move-left", [KEY_A, KEY_LEFT])
	_ensure_action("move-right", [KEY_D, KEY_RIGHT])


func _ensure_action(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k as Key
		InputMap.action_add_event(action, ev)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("bounce") and is_on_floor():
		velocity.y = jump_velocity
		$JumpSound.play()

	var direction: float = Input.get_axis("move-left", "move-right")
	if direction != 0:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Animation logic
	if not is_on_floor():
		$AnimatedSprite2D.play("bounce")
	elif direction != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()
	if is_on_floor() and absf(velocity.x) > 10:
		if not $walk.playing:
			$walk.play()
		else:
			$walk.stop()


func die() -> void:
	lives -= 1
	if lives <= 0:
		get_tree().call_deferred("reload_current_scene")
	$HurtSound.play()
	died.emit()
	call_deferred("_respawn")


func _respawn() -> void:
	global_position = start_position + Vector2(0, -foot_offset)
	velocity = Vector2.ZERO
