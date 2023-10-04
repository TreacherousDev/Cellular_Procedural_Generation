extends Node2D

var room = load("res://Scenes/Rooms/room_udlr.tscn")
#i got too lazy to refactor  this one but it's still pretty readable. 
#spawns a central room on first play to start the algorithm, deletes it and retries on clicking enter.
func _ready():
	var newRoom = room.instantiate()
	add_child(newRoom)
	newRoom.get_node("Sprite2D").modulate = Color(0,1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		spawn_room()
		
func spawn_room():
	get_child(2).queue_free()
	await get_tree().create_timer(0.1).timeout
	get_node("CanvasLayer/Label").count = 1
	var newRoom = room.instantiate()
	add_child(newRoom)
	newRoom.get_node("Sprite2D").modulate = Color(0,1,0)
