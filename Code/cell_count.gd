extends Label

var count := 1
var active := 1
var active_display

func _ready():
	update_active()

func update_active():
	pass
#	active_display = active
#	await get_tree().create_timer(0.3).timeout
#	update_active()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	count = get_tree().get_nodes_in_group("room").size()
	active = get_tree().get_nodes_in_group("active").size()
	text = "Cell Count: " + str(count) + "\nActive Nodes: " + str(active) + "\nIterations: " + str($"../..".iterations)


