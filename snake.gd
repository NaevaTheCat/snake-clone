extends Node2D

@onready var head: Area2D = %Head
@onready var movement_timer: Timer = %MovementTimer
@onready var snake_body: Node2D = $SnakeBody

signal ate
signal died

const SNAKE_BODYPARTS := [
	preload("res://assets/S.png"),
	preload("res://assets/N.png"),
	preload("res://assets/a.png"),
	preload("res://assets/k.png"),
	preload("res://assets/e.png")
]

# Add additional a's from here.
const SNAKE_GROWTH_IDX := 2

var move_seconds := 1.0
const TIME_SCALING_FACTOR = 0.9
var movement_direction: Vector2
var next_movement_direction := Vector2.RIGHT
var movement_tween: Tween

var grid_size := 32

var snake_length := 1
var grow_on_next_move := false

const ANIMATION_DURATION = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	head.area_entered.connect(_on_area_entered)
	load_snake()
	movement_timer.wait_time = move_seconds
	movement_timer.timeout.connect(move)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("snake"):
		emit_signal("died")
		var tween = create_tween()
		tween.tween_property(snake_body, "modulate", Color.DARK_RED, 0.5)
		tween.tween_property(snake_body, "modulate:a", 0.0, ANIMATION_DURATION)
	if area.is_in_group("food"):
		emit_signal("ate")
		grow_on_next_move = true
		movement_timer.wait_time = movement_timer.wait_time * TIME_SCALING_FACTOR

func _unhandled_input(event: InputEvent) -> void:
	if movement_direction == Vector2.RIGHT or movement_direction == Vector2.LEFT:
		if event.is_action_pressed("move_up"):
			set_next_movement_direction(Vector2.UP)
		if event.is_action_pressed("move_down"):
			set_next_movement_direction(Vector2.DOWN)
	if movement_direction == Vector2.UP or movement_direction == Vector2.DOWN:
		if event.is_action_pressed("move_left"):
			set_next_movement_direction(Vector2.LEFT)
		if event.is_action_pressed("move_right"):
			set_next_movement_direction(Vector2.RIGHT)

func set_next_movement_direction(direction: Vector2) -> void:
	next_movement_direction = direction
	# This nightmare makes sure it's always moving through the old movement direction
	var head_vector := Vector2.from_angle(head.rotation)
	var angle_to_neutral := head_vector.angle_to(movement_direction)
	var angle_to_next_from_neutral := movement_direction.angle_to(next_movement_direction)
	var total_angle := angle_to_neutral + angle_to_next_from_neutral
	var total_animation_time: float = min(ANIMATION_DURATION, movement_timer.time_left)
	var neutral_duration := total_animation_time * angle_to_neutral / total_angle
	var next_duration := total_animation_time - neutral_duration
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.tween_property(head, "rotation", head.rotation + angle_to_neutral, neutral_duration)
	movement_tween.tween_property(head, "rotation", head.rotation + angle_to_neutral + angle_to_next_from_neutral, next_duration)

func move() -> void:
	movement_direction = next_movement_direction
	var children_to_move := snake_body.get_child_count()
	# Don't move the "tail" if growing
	if grow_on_next_move:
		grow_snake()
		children_to_move = SNAKE_GROWTH_IDX + 1
	var next_position = head.position + grid_size * movement_direction
	for body_part_idx: int in range(children_to_move):
		var body_part: Area2D = snake_body.get_child(body_part_idx)
		var current_position := body_part.position
		var body_tween := create_tween()
		body_tween.tween_property(body_part, "position", next_position, ANIMATION_DURATION)
		#body_part.position = next_position
		if body_part != head:
			body_part.rotation = (next_position - current_position).angle()
			#var body_tween = create_tween()
			#var angle := Vector2.from_angle(body_part.rotation).angle_to(next_position - current_position)
			#body_tween.tween_property(body_part, "rotation", body_part.rotation + angle, ANIMATION_DURATION)
		next_position = current_position

func grow_snake() -> void:
	var growth_site := snake_body.get_child(SNAKE_GROWTH_IDX)
	var new_part := growth_site.duplicate()
	growth_site.add_sibling(new_part)
	grow_on_next_move = false

func load_snake() -> void:
	# Initialising the snake body
	for part_idx in range(1,5):
		var new_part: Area2D = head.duplicate()
		var last_part: Area2D = snake_body.get_child(part_idx - 1)
		new_part.get_node("Sprite2D").texture = SNAKE_BODYPARTS[part_idx]
		new_part.position = last_part.position - next_movement_direction * grid_size
		new_part.rotation = last_part.rotation
		last_part.add_sibling(new_part)
