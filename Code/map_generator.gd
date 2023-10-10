extends Node2D


#i got too lazy to refactor  this one but it's still pretty readable.


#you can edit the spawned room by changing the room variable.
#by default its set to the room with 4 open directions
var room = load("res://Scenes/Rooms/room_udlr.tscn") 

var count := 0
var active := 0
var iterations : int = 0

func _ready():
	create_map()

func _process(delta):
	$CanvasLayer/Label.text = "Cell Count: " + str(count) + "\nActive Nodes: " + str(active) + "\nIterations: " + str(iterations)
	
	if Input.is_action_just_pressed("ui_accept"):
		reset_map()
		iterations += 1

func _physics_process(delta):
	count = get_tree().get_nodes_in_group("room").size()
	active = get_tree().get_nodes_in_group("active").size()

func create_map():
	#spawns a room on first play to start the algorithm, deletes it and retries on clicking enter.
	var newRoom = room.instantiate()
	add_child(newRoom)
	newRoom.get_node("Sprite2D").modulate = Color(0,1,0)

func reset_map():
	get_child(2).queue_free()
	await get_tree().process_frame
	create_map()
	
