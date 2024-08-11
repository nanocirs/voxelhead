class_name HealthComponent
extends Node

signal on_health_initialized(max_health: int);
signal on_health_changed(current_health: int);
signal on_health_depleted();

@export var health_bar: ProgressBar = null;

var health: int = 0;


func set_health(value: int):
	health = value;
	on_health_changed.emit(health);

func initialize_health(value: int):
	health = value;
	on_health_initialized.emit(health);

func reduce_health(value: int):
	health = max(0, health - value);
	
	on_health_changed.emit(health);
	
	if health == 0:
		on_health_depleted.emit();
