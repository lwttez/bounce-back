extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# 只對玩家有反應（有 die() 的物體），地板、牆壁等其他物體忽略
	if body.has_method("die"):
		body.die()
