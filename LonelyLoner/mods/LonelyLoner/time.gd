extends Node

const ID = "LonelyLonerTimeAPI"
onready var real_time = {"hour": 0, "minute": 0, "second": 0}
onready var ingame_time = {"hour": 0, "minute": 0, "second": 0}

var min_timer = null
var sec_timer = null
var in_game_sec_timer = null
var lh_timer = null
var mode = "RealTime"
var check_lh = false
var ingame_second_length = 0.1

func _ready():
	print(ID + " has loaded!")
	check_time()
	match mode:
		"RealTime":
			create_timer(min_timer, 60, "check_time") # Set the interval at which to poll irl time
			create_timer(sec_timer, 1, "_poll_long_haul")
		"IngameTime":
			create_timer(min_timer, ingame_second_length, "check_time") # Set the interval at which to poll in game time
			create_timer(sec_timer, 1, "_poll_long_haul")
			create_timer(in_game_sec_timer, ingame_second_length, "_in_game_time_has_passed")

func create_timer(timer, wait_by, function):
	timer = Timer.new()
	timer.wait_time = wait_by
	add_child(timer)
	timer.connect("timeout", self, function)
	timer.start()
	return timer

func _in_game_time_has_passed():
	ingame_time["second"] = ingame_time["second"] + 1
	if ingame_time["second"] >= 60:
		ingame_time["second"] = 0
		ingame_time["minute"] = ingame_time["minute"] + 1
	if ingame_time["minute"] >= 60:
		ingame_time["minute"] = 0
		ingame_time["hour"] = ingame_time["hour"] + 1
	if ingame_time["hour"] >= 24:
		ingame_time = {"hour": 0, "minute": 0, "second": 0}

func check_time():
	match mode:
		"RealTime":
			real_time = Time.get_time_dict_from_system()
			print(ID + ": " + str(real_time)) # Just for debug to make sure it be working
			return real_time
		"IngameTime":
			print(ID + ": " + str(ingame_time)) # Just for debug to make sure it be working
			return ingame_time

# checks every second to see if it should switch to polling at a set interval
func _poll_long_haul():
	if check_lh == true:
		match mode:
			"RealTime":
				if real_time["minute"] == 30 || 0:
					lh_timer = _create_long_haul_timer(lh_timer, 1800, "check_time")
			"IngameTime":
				if ingame_time["minute"] == 30 || 0:
					pass # Call func that you want on that interval, will run multiple times, haven't done that logic yet

# remove polling every second and start running by set interval
func _create_long_haul_timer(timer, wait_by, function):
	if sec_timer != null:
		check_lh = false
		
		sec_timer.stop()
		sec_timer.disconnect("timeout", self, "check_time")
		remove_child(sec_timer)
		
		lh_timer = Timer.new()
		lh_timer.wait_time = wait_by
		add_child(lh_timer)
		lh_timer.connect("timeout", self, function)
		lh_timer.start()
		return lh_timer
	else:
		print(ID + ": lh_timer didn't start successfully") # Actual useful debug, keep

