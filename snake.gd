extends Node2D

@onready var head: Area2D = %Head
@onready var movement_timer: Timer = %MovementTimer
@onready var snake_body: Node2D = $SnakeBody

const SNAKE_BODYPARTS := [
	preload("res://assets/S.png"),
	preload("res://assets/N.png"),
	preload("res://assets/a.png"),
	preload("res://assets/k.png"),
	preload("res://assets/e.png")
]

var move_seconds := 1.0
var movement_direction := Vector2.RIGHT

var grid_size := 32

var snake_length := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_timer.wait_time = move_seconds
	movement_timer.timeout.connect(move)
	movement_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func move() -> void:
	# Initialising the snake body
	if snake_length < 5:
		var new_part := head.duplicate()
		new_part.get_node("Sprite2D").texture = SNAKE_BODYPARTS[snake_length]
		snake_body.get_child(snake_length - 1).add_sibling(new_part)
		snake_length += 1
	var next_position = head.position + grid_size * movement_direction
	for body_part: Area2D in snake_body.get_children():
		var current_position := body_part.position
		body_part.position = next_position
		next_position = current_position
