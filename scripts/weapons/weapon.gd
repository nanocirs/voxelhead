class_name Weapon
extends Node3D

signal on_weapon_fired();
signal on_hit(enemy: Enemy, hit_position: Vector3);

@export var muzzle: Node3D;
@export var muzzle_flash: OmniLight3D;
@export var enemy_collider: Area3D;

@export var damage: int = 20;
@export var weapon_range: float = 1000.0;
@export var fire_rate: float = 9;
@export var muzzle_flash_time: float = 0.075;

@export var collision_mask: int;

var enemies_on_sight: Array[Enemy] = [];

var timer_fire: float = 0.0;
var timer_muzzle_flash: float = 0.0;

var fire_period: float = 1.0 / fire_rate;
var is_fire_pressed: bool = false;

func _ready():
	subscribe_to_input_manager();
	muzzle_flash.visible = false;
	enemy_collider.body_entered.connect(func(entity): on_entity_enter_sight(entity));
	enemy_collider.body_exited.connect(func(entity): on_entity_leave_sight(entity));

func _physics_process(delta):
	timer_fire += delta;
	timer_muzzle_flash += delta;
	
	if timer_muzzle_flash > muzzle_flash_time:
		muzzle_flash.visible = false;
		timer_muzzle_flash = 0.0;
	
	if timer_fire > fire_period:
		if is_fire_pressed:
			fire_weapon();
			timer_fire = 0;
	
	if not is_fire_pressed:
		timer_fire = fire_period;

func fire_weapon():
	muzzle_flash.visible = true;

	on_weapon_fired.emit();
	
	if !enemies_on_sight.is_empty():
		var enemy_collision_mask: int = 2;
		var space_state = get_world_3d().direct_space_state;
		var query = PhysicsRayQueryParameters3D.create(global_position, enemies_on_sight.front().global_position, enemy_collision_mask, [self]);
		var result = space_state.intersect_ray(query);

		on_hit.emit(enemies_on_sight.front(), result.position);

func on_entity_enter_sight(entity: Node3D):
	if entity is Enemy:
		if entity in enemies_on_sight:
			return;
		
		enemies_on_sight.append(entity as Enemy);

func on_entity_leave_sight(entity: Node3D):
	if entity is Enemy:
		enemies_on_sight.erase(entity);

func subscribe_to_input_manager():
	InputManager.on_fire_pressed.connect(func(is_pressed): is_fire_pressed = is_pressed);
