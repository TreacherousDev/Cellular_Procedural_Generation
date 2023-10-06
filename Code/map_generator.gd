extends Node2D

var room = load("res://Scenes/Rooms/room_udlr.tscn")
#i got too lazy to refactor  this one but it's still pretty readable. 
#spawns a central room on first play to start the algorithm, deletes it and retries on clicking enter.
func _ready():
	var newRoom = room.instantiate()
	add_child(newRoom)
	newRoom.get_node("Sprite2D").modulate = Color(0,1,0)

var active
var is_zero : bool = false
var countdown : float = 0.3
var iterations : int = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		spawn_room()
	
	set_deferred("active", get_tree().get_nodes_in_group("active").size())
	if active == 0:
		countdown -= delta
	else:
		countdown = 0.3

	if countdown < 0 and get_tree().get_nodes_in_group("room").size() > 270:
		countdown = 0.3
		iterations += 1
		pass
		spawn_room()

func spawn_room():
	get_child(2).queue_free()
	await get_tree().create_timer(0.1).timeout
	get_node("CanvasLayer/Label").count = 1
	var newRoom = room.instantiate()
	add_child(newRoom)
	newRoom.get_node("Sprite2D").modulate = Color(0,1,0)
