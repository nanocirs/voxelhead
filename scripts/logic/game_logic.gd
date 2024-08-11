extends Node

@export var enemies_node: Node;

@onready var camera: Camera3D = $Camera;

var player_resource: Resource = preload("res://prefabs/entities/player.tscn");
var enemy_resource: Resource = preload("res://prefabs/entities/enemy_default.tscn");

var callback_kill_entity: Callable = func(entity: Entity): kill_entity(entity);
var callback_on_enemy_hit: Callable = func(enemy: Enemy): on_enemy_hit(enemy);

var player: Player;
var enemies: Array[Enemy] = [];
var camera_position: Vector3 = Vector3.ZERO;

func _ready():
	camera_position = camera.global_position;
	spawn_player(Vector3(0.0, 1.8, 0.0));
	spawn_enemy(Vector3(-10.0, 1.8, -15.0));
	spawn_enemy(Vector3(30.0, 1.8, 15.0));

func restart():
	await get_tree().create_timer(2.0).timeout;
	
	for enemy in enemies:
		enemy.queue_free();
	
	enemies.clear();
	
	camera.position = camera_position; 
	
	spawn_player(Vector3(0.0, 1.8, 0.0));
	spawn_enemy(Vector3(-10.0, 1.8, -15.0));
	spawn_enemy(Vector3(30.0, 1.8, 15.0));

func on_enemy_hit(enemy: Enemy):
	enemy.damage(GlobalProperties.weapon_damage);
	
func spawn_player(coordinates: Vector3):
	player = player_resource.instantiate() as Player;
	player.position = coordinates;
	player.camera = camera;
	add_child(player);
	player.on_death.connect(callback_kill_entity);
	player.weapon.on_hit.connect(callback_on_enemy_hit);

func spawn_enemy(coordinates: Vector3):
	var new_enemy : Enemy = enemy_resource.instantiate() as Enemy;
	new_enemy.position = coordinates;
	new_enemy.on_death.connect(callback_kill_entity);
	
	enemies_node.add_child(new_enemy);
	enemies.append(new_enemy);

func kill_entity(entity: Entity):
	if entity is Enemy:
		entity.on_death.disconnect(callback_kill_entity);
		enemies.erase(entity as Enemy);
		entity.queue_free();
		
	elif entity is Player:
		player.on_death.disconnect(callback_kill_entity);
		player.weapon.on_hit.disconnect(callback_on_enemy_hit);
		entity.queue_free();
		restart();
