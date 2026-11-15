extends Area2D

@export var bounce_force := 420

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.frame = 0

func _on_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.play("bounce")
	if "velocity" in body:
		body.velocity = Vector2.UP.rotated(global_rotation) * bounce_force
