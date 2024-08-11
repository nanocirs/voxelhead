class_name HealthBar
extends ProgressBar

@export var health_component: HealthComponent = null;

func _ready():
	health_component.on_health_initialized.connect(func(health: int): print(health); initialize_health(health));
	health_component.on_health_changed.connect(func(health: int): print(health); set_health(health));

func initialize_health(health: int):
	max_value = health;
	value = max_value;

func set_health(health: int):
	value = health;
