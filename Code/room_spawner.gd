extends Area2D

@onready var down = load("res://Scenes/Rooms/room_d.tscn")
@onready var downleft = load("res://Scenes/Rooms/room_dl.tscn")
@onready var downleftright = load("res://Scenes/Rooms/room_dlr.tscn")
@onready var downright = load("res://Scenes/Rooms/room_dr.tscn")
@onready var left = load("res://Scenes/Rooms/room_l.tscn")
@onready var leftright = load("res://Scenes/Rooms/room_lr.tscn")
@onready var right = load("res://Scenes/Rooms/room_r.tscn")
@onready var up = load("res://Scenes/Rooms/room_u.tscn")
@onready var updown = load("res://Scenes/Rooms/room_ud.tscn")
@onready var updownleft = load("res://Scenes/Rooms/room_udl.tscn")
@onready var updownleftright = load("res://Scenes/Rooms/room_udlr.tscn")
@onready var updownright = load("res://Scenes/Rooms/room_udr.tscn")
@onready var upleft = load("res://Scenes/Rooms/room_ul.tscn")
@onready var upleftright = load("res://Scenes/Rooms/room_ulr.tscn")
@onready var upright = load("res://Scenes/Rooms/room_ur.tscn")

#dictionary for room numbers, calculated by getting the sum of bit flags of the room. (updownleft = 1 + 2 + 4 = 7)
@onready var room_values = {1: up, 2:left, 3:upleft, 4:down, 5:updown, 6:downleft, 7:updownleft, 8:right, 9:upright, 10:leftright, 11:upleftright, 12:downright, 13:updownright, 14:downleftright, 15:updownleftright}
#bit flag for directions
var direction_number : int

#rng for random selection
var rng = RandomNumberGenerator.new()
#declare map size
var max_cell_count : int = 100

#declare room variables
var room
var spawnable_locations := []
var spawnable_rooms := []

func _ready():
	initiate_spawn_algorithm()

#executes methods in order. this method is also called by a child when a spawning error occurs, reusing the code.
#(i.e: 2 rooms are spawned on the same frame and their nodes collide)
func initiate_spawn_algorithm():
	set_direction()
	
	#time delay between room spawns. per physics frame is the fastest
	#you can use await get_tree().create_timer(timer_number).timeout for longer delays
	await get_tree().physics_frame
	
	setup_variables()
	detect_spawnable_areas()
	
	#entirely optional, but good for customization
	manipulate_map()
	
	#only spawn rooms at the end of the frame to prevent issues with calculations
	call_deferred("spawn_rooms")

#sets the must-have direction of the room that this node should spawn (opposite of current)
#assigns a bit flag for each direction
func set_direction():
	match(position):
		Vector2(0, 20):
			#Up
			direction_number = 1
		Vector2(20, 0):
			#Left
			direction_number = 2
		Vector2(0, -20):
			#Down
			direction_number = 4
		Vector2(-20, 0):
			#Right
			direction_number = 8

#resets state of arrays to empty in case code needs to be reused
func setup_variables():
	spawnable_locations = []
	spawnable_rooms = []
	
#gets the max number of directions that the spawned room can have based on von neumann neighborhood
func detect_spawnable_areas():
	$Up.force_raycast_update()
	if $Up.is_colliding() == false:
		spawnable_locations.append(1)
	$Left.force_raycast_update()
	if $Left.is_colliding() == false:
		spawnable_locations.append(2)
	$Down.force_raycast_update()
	if $Down.is_colliding() == false:
		spawnable_locations.append(4)
	$Right.force_raycast_update()
	if $Right.is_colliding() == false:
		spawnable_locations.append(8)
	spawnable_locations.append(direction_number)
	get_all_combinations(spawnable_locations)

#used to force the branch to only spawn non-closing rooms
func delete_closer_rooms_from_set():
	if spawnable_rooms.size() > 1:
		spawnable_rooms.erase(up)
		spawnable_rooms.erase(left)
		spawnable_rooms.erase(down)
		spawnable_rooms.erase(right)

#MUST READ!!!
#manipulate map generation with custom room pool, branch_depth can be used as a condition for more complex shaped maps
#if you dont want any modifications, clear / comment function body and replace it with pass instead
func manipulate_map():
	pass
	#EDITABLE PORTION
	#USE THIS TO MODIFY SPAWN CONDITIONS
	
	#FOR add_room_to_pool(room_type: PackedScene, frequency: int)
	#first parameter is the room type you want to manipulate
	#second is a number dictates how many times the value should be inserted (more times = better chance of spawning)
	
	#FOR delete_room_from_pool(room_type: PackedScene)
	#parameter is the room you want to exclude from spawning
	
	#you can use if statements that checks for certain variables like the branch depth
	#or the node's global position to manipulate how the map looks 
	
	#sample: (uncomment to apply modification)
	#if get_parent().branch_depth < 5:
	#	add_room_to_pool(updown, 10)
	#	add_room_to_pool(leftright, 10)

#methods to add or delete rooms from selection pool
#use these inside manipulate_map()
func add_room_to_pool(room_type: PackedScene, frequency: int):
	if (spawnable_rooms.has(room_type)):
		while (frequency > 0):
			spawnable_rooms.append(room_type)
			frequency -= 1
func delete_room_from_pool(room_type: PackedScene):
	if (spawnable_rooms.size() > 1):
		spawnable_rooms.erase(room_type)


#the next 2 functions are some magic math stuff that makes it so that the node can only spawn rooms 
#that are appropriate according to its von-Neumann neighbors.

#returns an array of all possible spawnable rooms based on the raycast outputs
func get_all_combinations(spawn_locs):
	generate_combinations(spawn_locs, [], 0, spawnable_rooms)
	return spawnable_rooms
#defines the loop that iterates through possible spawnable rooms
func generate_combinations(spawn_locs, current_combination, index, result):
	if index == spawn_locs.size():
		if current_combination.has(direction_number):
			var sum = 0
			for num in current_combination:
				sum += num
			spawnable_rooms.append(room_values[sum])
		return

	# Include current element in the combination
	generate_combinations(spawn_locs, current_combination + [spawn_locs[index]], index + 1, result)
	
	# Exclude current element from the combination
	generate_combinations(spawn_locs, current_combination, index + 1, result)

#self explanatory
func spawn_rooms():
	#since a spawnable_rooms size of 1 means that it only contains a closing room,
	#so we remove it from the group of active nodes in advance
	if spawnable_rooms.size() == 1:
		remove_from_group("active")

	var active_nodes = get_tree().get_nodes_in_group("active").size()
	var cell_count = get_tree().get_nodes_in_group("room").size()
	
	#delete closing rooms from options if the map has a high tendency to close by chance
	if (active_nodes <= (8)):
		delete_closer_rooms_from_set()
	
	#SPAWNING PROCESS
	#selects a room to spawn based on the available room selection
	var num = rng.randi_range(1, spawnable_rooms.size())
	
	#spawns a random available rooom if max rooms is not yet achieved, spawns a closing room if it is.
	if (cell_count < max_cell_count):
		room = spawnable_rooms[num-1]
		max_cell_count -= 1
	else:
		room = room_values[direction_number]
	var newRoom = room.instantiate()
	
	#deletes the matching spawning node of the child to prevent it from attempting to spawn a room ontop of its parent
	#free is used instead of queue_free because we dont want it to be added to the active node count, whihc will mess up with our calculations
	match(direction_number):
		1:
			newRoom.get_node("Up").free()
		2:
			newRoom.get_node("Left").free()
		4:
			newRoom.get_node("Down").free()
		8:
			newRoom.get_node("Right").free()
	
	#insert room to scene and apply respective branch depth
	#branch depth can be used as a parameter for custom map designs (see manipulate map function)
	newRoom.branch_depth = get_parent().branch_depth + 1
	add_child(newRoom)
	
	#once finished spawning, make inactive.
	remove_from_group("active")

#if this node collides with another spawner node (which means on the next turn they will have to share the same cell), deletes parents and tries again as to avoid conflict
func _on_area_entered(area):
	if (area.is_in_group("room_spawnpoint")):
		if (get_parent().branch_depth >= area.get_parent().branch_depth):
			if (!get_parent().get_parent().is_in_group("active")):
				remove_from_group("active")
				
				get_parent().get_parent().add_to_group("active")
				get_parent().get_parent().call_deferred("initiate_spawn_algorithm")
				get_parent().queue_free()

