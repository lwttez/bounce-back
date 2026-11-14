extends Area2D

func _ready() -> void:
	body_entered.connect(func(_b: Node2D) -> void: queue_free())
