extends Node2D

@export var coin_scene: PackedScene
@export var spring_scene: PackedScene
@export var coin_count := 5
@export var area := Rect2(30, 30, 320, 200)
@export var min_gap := 50.0
@export var spike_count := 5
@export var spike_area := Rect2(50, 40, 300, 190)
@export var spike_min_gap := 70.0
@export var spike_clear := 40.0
@export var respawn_spikes_on_death := true
@export var floor_y := 250.0
@export var start_pos := Vector2(30, 250)
@export var goal_pos := Vector2(370, 250)
@onready var game_over_screen: CanvasLayer = $GameOver
@onready var restart_button: Button = $GameOver/RestartButton
@onready var win_screen: TextureRect = $UI/WinScreen


var placed: Array[Vector2] = []
var player: CharacterBody2D
var finished := false
var started := false
var placer_node
var spike_nodes: Array[Node] = []
var heart_textures = [preload("res://assets/UI/零命.png"), preload("res://assets/UI/一顆愛心.png"), preload("res://assets/UI/兩顆愛心.png"), preload("res://assets/UI/三顆愛心.png")]
var coins_remaining: int = 0

func _ready() -> void:
	game_over_screen.hide()
	win_screen.hide()
	randomize()
	var cam := Camera2D.new()
	cam.position = Vector2(200, 150)
	cam.zoom = Vector2(2, 2)
	add_child(cam)
	_make_walls()
	placed.append(start_pos)
	placed.append(goal_pos)
	_spawn(coin_scene, coin_count)
	_spawn_spikes()
	_make_start_and_goal()
	_make_player()
	placer_node = preload("res://scripts/placer.gd").new()
	add_child(placer_node)
	placer_node.process_mode = Node.PROCESS_MODE_DISABLED
	player.set_physics_process(false)
	$UI/StartButton.pressed.connect(start_game)
	if player.has_signal("game_over"):
		player.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)

func _make_walls() -> void:
	var body := StaticBody2D.new()
	add_child(body)
	_add_wall(body, Vector2(-10, 150), Vector2(20, 400))
	_add_wall(body, Vector2(410, 150), Vector2(20, 400))
func _add_wall(body: StaticBody2D, pos: Vector2, size: Vector2) -> void:
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	cs.shape = shape
	cs.position = pos
	body.add_child(cs)

func _make_start_and_goal() -> void:
	var start := Node2D.new()
	start.set_script(preload("res://scripts/start_point.gd"))
	start.position = start_pos
	add_child(start)
	var goal := Area2D.new()
	goal.set_script(preload("res://scripts/goal.gd"))
	goal.position = goal_pos
	add_child(goal)
	goal.connect("reached", _on_goal_reached)

func _make_player() -> void:
	var slime_scene: PackedScene = null
	if ResourceLoader.exists("res://scenes/slime.tscn"):
		slime_scene = load("res://scenes/slime.tscn") as PackedScene
	var foot := 11.0
	if slime_scene != null:
		player = slime_scene.instantiate() as CharacterBody2D
		foot = 5.0
	player.set("start_position", start_pos)
	player.position = start_pos + Vector2(0, -foot)
#	if player.has_signal("died"):
#		player.connect("died", _on_player_died)
	add_child(player)

func _on_game_over() -> void:
	game_over_screen.show()
	get_tree().paused = true

func _on_restart_pressed() -> void:
	set_physics_process(true)
	get_tree().paused = false
	get_tree().reload_current_scene()

#func _on_player_died() -> void:
#	if respawn_spikes_on_death:
#		call_deferred("_respawn_spikes")

func _respawn_spikes() -> void:
	for s in spike_nodes:
		if is_instance_valid(s):
			s.queue_free()
	spike_nodes.clear()
	_spawn_spikes()

func _on_goal_reached() -> void:
	if finished:
		return
	if get_tree().get_nodes_in_group("coins").size() > 0:
		return
	finished = true
	$UI/Hearts.hide()
	for child in get_children():
		if child is CanvasItem:
			child.hide()
	win_screen.show()
	$UI/WinSound.play()
	
	get_tree().paused = true


func _spawn_spikes() -> void:
	var scene := load("res://scenes/spike.tscn") as PackedScene
	if scene == null:
		return
	var spikes: Array[Vector2] = []
	var tries := 0
	var gap := spike_min_gap
	var clear := spike_clear
	while spikes.size() < spike_count and tries < 3000:
		tries += 1
		if tries % 200 == 0:
			gap *= 0.8
			clear *= 0.7
		var p := Vector2(
			randf_range(spike_area.position.x, spike_area.end.x),
			randf_range(spike_area.position.y, spike_area.end.y))
		var ok := true
		for q in spikes:
			if p.distance_to(q) < gap:
				ok = false
				break
		for c in placed:
			if p.distance_to(c) < clear:
				ok = false
				break
		if not ok:
			continue
		spikes.append(p)
		var s := scene.instantiate() as Node2D
		s.position = p
		s.rotation_degrees = float(randi_range(0, 11)) * 15.0
		add_child(s)
		spike_nodes.append(s)

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
		if n.has_signal("collected"):
			n.collected.connect(_on_coin_collected)
			coins_remaining += 1
		add_child(n)
		made += 1



func _on_coin_collected() -> void:
	coins_remaining -= 1
		
func _process(_delta):
	if player == null:
		return
	var n = player.get("lives")
	if n != null:
		$UI/Hearts.texture = heart_textures[clampi(n, 0, 3)]
		
func start_game() -> void:
	placer_node.process_mode = Node.PROCESS_MODE_INHERIT
	if started:
		return
	started = true
	$UI/StartScreen.visible = false
	$UI/StartButton.visible = false
	player.set_physics_process(true)
