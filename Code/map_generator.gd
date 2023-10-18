extends Node2D


#i got too lazy to refactor  this one but it's still pretty readable.


#you can edit the spawned room by changing the room variable.
#by default its set to the room with 4 open directions
var room = load("res://Scenes/Rooms/room_udlr.tscn") 


var count := 0
var active := 1
var iterations : int = 0

#spawns a room on first play to start the algorithm, deletes it and retries on clicking enter.
func _ready():
	create_map()

var has_printed := false

func _process(delta):
	$CanvasLayer/Label.text = " Cell Count: " + str(count) + "\n Active Nodes: " + str(active) + "\n Iterations: " + str(iterations)
	


func _physics_process(delta):
	count = get_tree().get_nodes_in_group("room").size()
	active = get_tree().get_nodes_in_group("active").size()
	
	if Input.is_action_just_pressed("ui_accept"):
		reset_map()
		iterations += 1
		
# WIP TODO: resets map if it generates a map smaller than intended
#	if active == 0 and 300 > count:
#		call_deferred("reset_map")
#		reset_map()
		
func create_map():
	var newRoom = room.instantiate()
	add_child(newRoom)
	#set main room color to green
	newRoom.get_node("Sprite2D").modulate = Color(0,1,0)

func reset_map():
	get_child(2).queue_free()
	await get_tree().process_frame
	create_map()
	
