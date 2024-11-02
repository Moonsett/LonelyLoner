extends Node

const ID = "LonelyLonerTimeAPI"
onready var irl_time = null
onready var in_game_time = [23, 55, 0]

var min_timer = null
var sec_timer = null
var in_game_sec_timer = null
var lh_timer = null
var mode = "irl"
var check_lh = true
var how_long_an_ig_sec_is = 0.1

func _ready():
	print(ID + " has loaded!")
	check_time()
	match mode:
		"irl":
			create_timer(min_timer, 60, "check_time") # Set the interval at which to poll irl time
			create_timer(sec_timer, 1, "_poll_long_haul")
		"ig":
			create_timer(min_timer, how_long_an_ig_sec_is, "check_time") # Set the interval at which to poll in game time
			create_timer(sec_timer, 1, "_poll_long_haul")
			create_timer(in_game_sec_timer, how_long_an_ig_sec_is, "_in_game_time_has_passed")

func create_timer(timer, wait_by, function):
	timer = Timer.new()
	timer.wait_time = wait_by
	add_child(timer)
	timer.connect("timeout", self, function)
	timer.start()
	return timer

func _in_game_time_has_passed():
	in_game_time[2] = in_game_time[2] + 1
	if in_game_time[2] >= 60:
		in_game_time[2] = 0
		in_game_time[1] = in_game_time[1] + 1
	if in_game_time[1] >= 60:
		in_game_time[1] = 0
		in_game_time[0] = in_game_time[0] + 1
	if in_game_time[0] >= 24:
		in_game_time = [0, 0, 0]

func check_time():
	match mode:
		"irl":
			irl_time = Time.get_time_dict_from_system()
			print(ID + ": " + str(irl_time)) # Just for debug to make sure it be working
			return irl_time
		"ig":
			print(ID + ": " + str(in_game_time)) # Just for debug to make sure it be working
			return in_game_time

# checks every second to see if it should switch to polling at a set interval
func _poll_long_haul():
	if check_lh == true:
		match mode:
			"irl":
				if irl_time["minute"] == 30 || 0:
					lh_timer = _create_long_haul_timer(lh_timer, 1800, "check_time")
			"ig":
				if in_game_time[1] == 30 || 0:
					pass # Call func that you want on that interval, will run multiple times, haven't done that logic yet

# remove polling every second and start running by set interval
func _create_long_haul_timer(timer, wait_by, function):
	if sec_timer != null:
		check_lh = false
		
		sec_timer.stop()
		sec_timer.disconnect("timeout", self, "check_time")
		remove_child(sec_timer)
		
		var lh_timer = Timer.new()
		lh_timer.wait_time = wait_by
		add_child(lh_timer)
		lh_timer.connect("timeout", self, function)
		lh_timer.start()
		return lh_timer
	else:
		print(ID + ": lh_timer didn't start successfully") # Actual useful debug, keep

