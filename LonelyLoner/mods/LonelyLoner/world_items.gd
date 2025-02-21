extends Spatial

onready var LonelyLoner = get_node_or_null("/root/LonelyLoner")
onready var time = LonelyLoner.check_time()
var current_state = null
var new_state = null

func _load():
	match time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			visible = true
		5, 6, 7:
			visible = false
		17, 18, 19:
			visible = true
		8, 9, 10, 11, 12, 13, 14, 15, 16:
			visible = false

func _set_visibility_by_time():
	var time = LonelyLoner.check_time()

	match time["hour"]:
		17, 18, 19, 20, 21, 22, 23, 24, 0, 1, 2, 3, 4:
			new_state = "fade_in"
		5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16:
			new_state = "fade_out"
		_:
			print("Failed to get hour.")

	if new_state != current_state:
		current_state = new_state
		match current_state:
			"fade_in":
				$Anim.play("Show")
				if not visible:
					visible = true
			"fade_out":
				$Anim.play("Hide")
			"hidden":
				visible = false

func _ready():
	LonelyLoner.connect("hour_has_passed", self, "_set_visibility_by_time")

func _physics_process(delta):
	pass
