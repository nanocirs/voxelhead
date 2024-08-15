class_name Enemy
extends Entity

signal on_attack(damage_value);

@onready var collider: CollisionShape3D = $Collider;

@export var attack_time: float = 2;

var is_alive: bool = true;

var blood_resource: Resource = preload("res://prefabs/decals/blood.tscn");

var damage_value: int = GlobalProperties.enemy_damage;
var player: Player = null;
var is_knockback_applied: bool = false;
var is_attacking: bool = false;
var timer_attack: float = 0.0;

func _ready():
	super();

func _process(delta: float):
	if is_alive:
		timer_attack += delta;

	if timer_attack > attack_time:
		on_attack.emit(damage_value);
		timer_attack = 0.0;

func _physics_process(delta: float):
	if is_instance_valid(player) and player.is_alive and is_alive:
		move(delta);

func initialize_enemy():
	player = GameState.player;
	health_component.initialize_health(GlobalProperties.enemy_health);	

func move(delta: float):
	if not player:
		return;
	
	var direction: Vector3 = player.global_position - self.position;
	direction.y = 0.0;
	
	var target_velocity: Vector3 = Vector3.ZERO;
	
	if direction != Vector3.ZERO:
		direction = direction.normalized();
		
		basis = lerp(basis, Basis.looking_at(direction), turn_speed * delta);
		
		target_velocity.x = direction.x * speed;
		target_velocity.z = direction.z * speed;
		
	if is_knockback_applied:
		target_velocity += -direction * GlobalProperties.knockback_force;
		is_knockback_applied = false;
	
	if not is_on_floor():
		target_velocity.y += GlobalProperties.gravity * delta;
	
	velocity = target_velocity;
	move_and_slide();

func damage(value: int):
	super(value);
	apply_knockback();

func bleed(pos: Vector3):
	var blood: Decal = blood_resource.instantiate();
	var rear_blood: Decal = blood_resource.instantiate();
	add_child(blood);
	add_child(rear_blood);

	blood.global_position = pos;
	rear_blood.position = -blood.position;
	randomize_blood(blood);
	randomize_blood(rear_blood);
	rear_blood.position.z = -blood.position.z;

func randomize_blood(blood: Decal):
	var blood_size: float = randf_range(0.2, 0.9);
	blood.scale = Vector3(blood_size, 0.2, blood_size);
	blood.rotate_x(PI / 2.0);
	blood.position.x = randf_range(blood.position.x - 1.0, blood.position.x + 1.0);
	blood.position.y = randf_range(blood.position.y - 1.0, blood.position.y + 1.0);

func apply_knockback():
	is_knockback_applied = true;

func reset_cooldown_attack():
	timer_attack = attack_time;

func kill():
	self.is_alive = false;
	
	collider.disabled = true;

	var tween_rot = get_tree().create_tween();
	tween_rot.tween_property(self, "rotation", Vector3(PI / 2.0, rotation.y, rotation.z), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN);
	
	await get_tree().create_timer(0.2).timeout;
	var tween_pos = get_tree().create_tween();
	tween_pos.tween_property(self, "position", Vector3(position.x, 1.2, position.z), 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT);
