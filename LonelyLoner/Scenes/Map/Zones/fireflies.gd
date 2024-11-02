extends Spatial

onready var time = TimeAPI.check_time()

func _set_visibility_by_time():
	match time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			visible = true
		5, 6, 7:
			visible = false
		17, 18, 19:
			visible = true
		8, 9, 10, 11, 12, 13, 14, 15, 16:
			visible = false
		_:
			print(str(self) + ": WHERE ARE YOU?!?! (could not set visibility by hour because hour is either overflowed or doesn't exist)")

func _ready():
	pass

func _process(delta):
	time = TimeAPI.check_time()
	_set_visibility_by_time()
