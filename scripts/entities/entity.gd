class_name Entity
extends CharacterBody3D

signal on_death(this);

@export var speed: float = 12.0;
@export var turn_speed: float = 20.0;

@onready var health_component: HealthComponent = $HealthComponent;

func _ready():
	health_component.on_health_depleted.connect(func(): die());

func damage(damage_value: int):
	health_component.reduce_health(damage_value);

func die():
	on_death.emit(self);
