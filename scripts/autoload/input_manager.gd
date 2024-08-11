extends Node

signal on_move_left_pressed(is_pressed);
signal on_move_right_pressed(is_pressed);
signal on_move_up_pressed(is_pressed);
signal on_move_down_pressed(is_pressed);
signal on_zoom_in_pressed();
signal on_zoom_out_pressed();
signal on_fire_pressed(is_pressed);


func _physics_process(_delta):
	if Input.is_action_just_pressed("move_left"):
		on_move_left_pressed.emit(true);
	if Input.is_action_just_released("move_left"):
		on_move_left_pressed.emit(false);
	if Input.is_action_just_pressed("move_right"):
		on_move_right_pressed.emit(true);
	if Input.is_action_just_released("move_right"):
		on_move_right_pressed.emit(false);
	if Input.is_action_just_pressed("move_up"):
		on_move_up_pressed.emit(true);
	if Input.is_action_just_released("move_up"):
		on_move_up_pressed.emit(false);
	if Input.is_action_just_pressed("move_down"):
		on_move_down_pressed.emit(true);
	if Input.is_action_just_released("move_down"):
		on_move_down_pressed.emit(false);
	if Input.is_action_just_pressed("zoom_in"):
		on_zoom_in_pressed.emit();
	if Input.is_action_just_pressed("zoom_out"):
		on_zoom_out_pressed.emit();
	if Input.is_action_just_pressed("fire"):
		on_fire_pressed.emit(true);
	if Input.is_action_just_released("fire"):
		on_fire_pressed.emit(false);
