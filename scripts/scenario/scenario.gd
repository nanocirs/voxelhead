extends Node3D

@onready var enemy_spawn_points_container: Node = $EnemySpawnPoints;

var blood_resource: Resource = preload("res://prefabs/decals/blood.tscn");

var enemy_spawn_points: Array[Vector3] = [];

func _ready():
	for i in enemy_spawn_points_container.get_children():
		enemy_spawn_points.append(i.global_position);

func get_random_enemy_spawn_point() -> Vector3:
	var index: int = randi_range(0, enemy_spawn_points.size() - 1);
	return enemy_spawn_points[index];

func paint(pos: Vector3):
	for i in range(randi_range(1,4)):
		spawn_blood(pos);

func spawn_blood(pos: Vector3):
	var blood: Decal = blood_resource.instantiate();
	add_child(blood);
	blood.global_position = pos;
	randomize_blood(blood);
	blood.cull_mask = 1;
	
func randomize_blood(blood: Decal):
	var blood_size: float = randf_range(1.0, 6.0);

	var tween = get_tree().create_tween();
	tween.tween_property(blood, "scale", Vector3(blood_size, blood_size, blood_size), 5.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT);
	
	var blood_rotation: float = randf_range(0, 2.0 * PI);
	blood.rotate_y(blood_rotation);
