extends Area2D

@export var bounce_force := 420.0   # 彈力，依你的跳躍速度調整

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.frame = 0

func _on_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.play("bounce")
	if "velocity" in body:
		# 沿著跳板「朝上」的方向彈射，所以旋轉跳板就能改變彈射方向
		body.velocity = Vector2.UP.rotated(global_rotation) * bounce_force
