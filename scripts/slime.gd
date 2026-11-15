extends CharacterBody2D
signal died

@export var speed: float = 150
@export var jump_velocity: float = -400
@export var foot_offset: float = 5.0

var start_position := Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if not is_on_floor():
		$AnimatedSprite2D.play("bounce")
	elif direction != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
	move_and_slide()

func die() -> void:
	died.emit()
	call_deferred("_respawn")

func _respawn() -> void:
	global_position = start_position + Vector2(0, -foot_offset)
	velocity = Vector2.ZERO
