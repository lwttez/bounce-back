extends CharacterBody2D
signal died
signal game_over

@export var speed: float = 150
@export var jump_velocity: float = -400
@export var foot_offset: float = 5.0


var start_position := Vector2.ZERO
var lives: int = 3
var is_dead: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		$JumpSound.play()
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
	if is_on_floor() and absf(velocity.x) > 10:
		var s = $LowWalkSound if lives == 1 else $walk
		if not s.playing:
			s.play()
	else:
		$walk.stop()
		$LowWalkSound.stop()

#func die() -> void:
#	lives -= 1
#	if lives <= 0:
#		get_tree().call_deferred("reload_current_scene")
#		$HurtSound.play()
#		died.emit()
#		call_deferred("_respawn") 
	
func die() -> void:
	if is_dead:
		return
	is_dead = true
	lives -= 1
	$HurtSound.play()
	died.emit()
	if lives <= 0:
		game_over.emit()
		hide()
		set_physics_process(false)
		return
	call_deferred("_respawn")

func _respawn() -> void:
	global_position = start_position + Vector2(0, -foot_offset)
	velocity = Vector2.ZERO
	is_dead = false
