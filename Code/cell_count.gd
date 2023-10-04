extends Label

var count := 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	count = get_tree().get_nodes_in_group("room").size()
	text = "Cell Count: " + str(count)


