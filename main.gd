extends Node

@onready var snake: Node2D = $Snake
@export var food_scene: PackedScene

var game_points := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snake.ate.connect(score_point)
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game() -> void:
	snake.position = Vector2(512.0, 320.0)
	get_tree().call_group("food", "queue_free")
	spawn_food()
	$Snake/MovementTimer.wait_time = 0.3
	$Snake/MovementTimer.start()

func score_point() -> void:
	game_points += 1
	spawn_food()
	
func spawn_food() -> void:
	var food = food_scene.instantiate()
	food.position = Vector2(randi_range(0,32) * 32.0, randi_range(0, 10) * 32.0)
	add_child.call_deferred(food)
