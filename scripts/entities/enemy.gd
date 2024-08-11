class_name Enemy
extends Entity

signal on_attack(damage_value);

@export var attack_time: float = 2;

var damage_value: int = GlobalProperties.enemy_damage;
var player: Player = null;
var is_knockback_applied: bool = false;
var is_attacking: bool = false;

var timer_attack: float = 0.0;


func _ready():
	super();
	initialize_enemy();

func _process(delta: float):
	timer_attack += delta;

	if timer_attack > attack_time:
		on_attack.emit(damage_value);
		timer_attack = 0.0;

func _physics_process(delta: float):
	if player != null:
		move(delta);

func initialize_enemy():
	player = GameState.player;
	health_component.initialize_health(GlobalProperties.enemy_health);	

func move(delta: float):
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

func apply_knockback():
	is_knockback_applied = true;

func reset_cooldown_attack():
	timer_attack = 0.0;
