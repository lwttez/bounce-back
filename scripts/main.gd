extends Node2D

@export var coin_scene: PackedScene
@export var spring_scene: PackedScene
@export var coin_count := 8
@export var spring_count := 8
@export var area := Rect2(30, 30, 320, 200)
@export var min_gap := 50.0

var placed: Array[Vector2] = []

func _ready() -> void:
	randomize()
	_spawn(coin_scene, coin_count)
	_spawn(spring_scene, spring_count)

func _spawn(scene: PackedScene, count: int) -> void:
	if scene == null:
		return
	var made := 0
	var tries := 0
	while made < count and tries < 1000:
		tries += 1
		var p := Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y))
		var ok := true
		for q in placed:
			if p.distance_to(q) < min_gap:
				ok = false
				break
		if not ok:
			continue
		placed.append(p)
		var n := scene.instantiate()
		n.position = p
		add_child(n)
		made += 1
