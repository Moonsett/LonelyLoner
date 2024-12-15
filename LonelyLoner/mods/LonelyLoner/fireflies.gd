extends Spatial

onready var LonelyLoner = get_node_or_null("/root/LonelyLoner")
onready var time = LonelyLoner.check_time()

func _load():
	match time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			visible = true
		5, 6, 7:
			visible = false
		17, 18, 19:
			visible = true
		5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16:
			visible = false

func _set_visibility_by_time():
	time = LonelyLoner.check_time()
	match time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			$Fading.play("FadeIn")
			if visible == false: visible = true
		5, 6, 7:
			$Fading.play("FadeOut")
		17, 18, 19:
			$Fading.play("FadeIn")
			if visible == false: visible = true
		5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16:
			$Fading.play("FadeOut")
		_:
			visible = false
			print(str(self) + ": WHERE ARE YOU?!?! (could not set visibility by hour because hour is either overflowed or doesn't exist)")

func _ready():
	_load()
	LonelyLoner.connect("hour_has_passed", self, "_set_visibility_by_time")

func _physics_process(delta):
	pass
	#_set_visibility_by_time()
