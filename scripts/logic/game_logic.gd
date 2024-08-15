extends Node

@export var enemies_node: Node;

@onready var scenario: Node3D = $Scenario;
@onready var camera: Camera3D = $Camera;

var player_resource: Resource = preload("res://prefabs/entities/player.tscn");
var enemy_resource: Resource = preload("res://prefabs/entities/enemy_default.tscn");

var callback_kill_entity: Callable = func(entity: Entity): kill_entity(entity);
var callback_on_enemy_hit: Callable = func(enemy: Enemy, position: Vector3): on_enemy_hit(enemy, position);

var player: Player;
var enemies: Array[Enemy] = [];
var camera_position: Vector3 = Vector3.ZERO;

var match_round: int = 1;

var enemy_spawn_queue: int = 0;


func _ready():
	camera_position = camera.global_position;
	spawn_player(Vector3(0.0, 2.0, 0.0));
	set_round(0);

func _process(_delta):
	if is_instance_valid(player) and player.is_alive:
		for i in range(enemy_spawn_queue):
			spawn_enemy();
		
		if enemies.is_empty():
			print("KPS")
			set_round(match_round + 1);

func set_round(new_round: int):
	match_round = new_round;

	for i in new_round:
		for j in 5:
			spawn_enemy();

func restart():
	enemy_spawn_queue = 0;
	
	var tween = get_tree().create_tween();
	tween.tween_property(camera, "global_position", camera_position, 2.0).set_trans(Tween.TRANS_CUBIC);
	
	for enemy in enemies:
		var enemy_tween = get_tree().create_tween();
		enemy_tween.tween_property(enemy, "global_position", Vector3(0.0, 100.0, 0.0), 4.5).set_trans(Tween.TRANS_EXPO);
		enemy_tween.tween_callback(enemy.queue_free);
		
	enemies.clear();
	
	await get_tree().create_timer(2.5).timeout;
	
	camera.position = camera_position; 
	
	spawn_player(Vector3(0.0, 1.8, 0.0));
	set_round(0);

func on_enemy_hit(enemy: Enemy, position: Vector3):
	enemy.damage(GlobalProperties.weapon_damage);
	enemy.bleed(position);
	
func spawn_player(coordinates: Vector3):
	var player_node = player_resource.instantiate() as Player;
	player_node.position = coordinates;
	player_node.camera = camera;
	add_child(player_node);
	player_node.on_death.connect(callback_kill_entity);
	player_node.weapon.on_hit.connect(callback_on_enemy_hit);
	
	player = player_node;

func spawn_enemy():
	var enemy_spawn_point: Vector3 = scenario.get_random_enemy_spawn_point();
	
	if (player != null and player.global_position.distance_to(enemy_spawn_point) < GlobalProperties.enemy_spawn_distance):
		enemy_spawn_queue += 1;
		return;
	
	for enemy in enemies:
		if (enemy.global_position.distance_to(enemy_spawn_point) < GlobalProperties.enemy_spawn_distance):
			enemy_spawn_queue += 1;
			return;

	enemy_spawn_queue -= 1;
	
	var new_enemy : Enemy = enemy_resource.instantiate() as Enemy;
	new_enemy.position = enemy_spawn_point;
	new_enemy.on_death.connect(callback_kill_entity);
	
	enemies_node.add_child(new_enemy);
	enemies.append(new_enemy);

	new_enemy.initialize_enemy();


func kill_entity(entity: Entity):
	if entity is Enemy:
		scenario.paint(entity.global_position);
		entity.on_death.disconnect(callback_kill_entity);
		enemies.erase(entity as Enemy);
		entity.kill();
		
	elif entity is Player:
		player.on_death.disconnect(callback_kill_entity);
		player.weapon.on_hit.disconnect(callback_on_enemy_hit);
		player.is_alive = false;
		entity.queue_free();
		restart();
