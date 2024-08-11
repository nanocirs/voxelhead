class_name Player
extends Entity

@export var camera: Camera3D;

@export var camera_zoom_min: float = 5.0;
@export var camera_zoom_max: float = 128.0;
@export var zoom_speed: float = 4.0;
@export var zoom_lerp_constant: float = 5.0;

@onready var weapon: Weapon = $Weapon;
@onready var damage_collider: Area3D = $DamageCollider;

var enemy_damage_callback: Callable = func(damage_value): damage(damage_value);
var enemies_attacking: Array[Enemy] = [];

var input_direction: Vector3 = Vector3.ZERO;
var target_zoom: float = 0.0;
var camera_size_i: float = 0.0;

var is_move_left_pressed: bool = false;
var is_move_right_pressed: bool = false; 
var is_move_up_pressed: bool = false;
var is_move_down_pressed: bool = false;
var is_zoom_in_pressed: bool = false;
var is_zoom_out_pressed: bool = false;

func _init():
	GameState.player = self;

func _ready():
	super();
	subscribe_to_input_manager();
	initialize_player();

func _physics_process(delta: float):
	process_input();
	move_player(input_direction, delta);
	zoom_camera(delta);

func initialize_player():
	health_component.initialize_health(GlobalProperties.player_health);
	health_component.on_health_depleted.connect(func(): die());
	
	damage_collider.body_entered.connect(func(entity): on_entity_touching_player(entity));
	damage_collider.body_exited.connect(func(entity): on_entity_stop_touching_player(entity));
	
	if camera:
		camera_size_i = camera.size;
	
func process_input():
	input_direction = Vector3.ZERO;
	target_zoom = 0;
	
	if is_move_left_pressed:
		input_direction.z += -1;
	if is_move_right_pressed:
		input_direction.z += 1;
	if is_move_up_pressed:
		input_direction.x += 1;
	if is_move_down_pressed:
		input_direction.x += -1;
	if is_zoom_in_pressed:
		camera_size_i = max(camera_zoom_min, camera_size_i - zoom_speed);
		is_zoom_in_pressed = false;
	if is_zoom_out_pressed:
		camera_size_i = min(camera_zoom_max, camera_size_i + zoom_speed);
		is_zoom_out_pressed = false;

func move_player(input: Vector3, delta: float):
	var player_position: Vector3 = global_position;
	var target_velocity: Vector3 = Vector3.ZERO;
	
	if input != Vector3.ZERO:
		input = input.normalized();
		
		basis = lerp(basis, Basis.looking_at(input), turn_speed * delta);
		
		target_velocity.x = input.x * speed;
		target_velocity.z = input.z * speed;

	if not is_on_floor():
		target_velocity.y += GlobalProperties.gravity * delta;
	
	velocity = target_velocity;
	move_and_slide();
	
	var position_delta: Vector3 = position - player_position;
	position_delta.y = 0.0;
	
	if camera:
		camera.position += position_delta;

func zoom_camera(delta: float):
	if camera:
		camera.size = clampf(lerpf(camera.size, camera_size_i, zoom_lerp_constant * delta), camera_zoom_min, camera_zoom_max);

func on_entity_touching_player(entity: Node3D):
	if entity is Enemy:
		entity.on_attack.connect(enemy_damage_callback);
		entity.reset_cooldown_attack();

func on_entity_stop_touching_player(entity: Node3D):
	if entity is Enemy:
		entity.on_attack.disconnect(enemy_damage_callback);

func subscribe_to_input_manager():
	InputManager.on_move_left_pressed.connect(func(is_pressed): is_move_left_pressed = is_pressed);
	InputManager.on_move_right_pressed.connect(func(is_pressed): is_move_right_pressed = is_pressed);
	InputManager.on_move_up_pressed.connect(func(is_pressed): is_move_up_pressed = is_pressed);
	InputManager.on_move_down_pressed.connect(func(is_pressed): is_move_down_pressed = is_pressed);
	InputManager.on_zoom_in_pressed.connect(func(): is_zoom_in_pressed = true);
	InputManager.on_zoom_out_pressed.connect(func(): is_zoom_out_pressed = true);
