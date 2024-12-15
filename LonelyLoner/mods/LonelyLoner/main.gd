extends Node

signal second_has_passed
signal minute_has_passed
signal hour_has_passed
signal day_has_passed

const ID = "LonelyLoner"
onready var real_time = {"hour": 0, "minute": 0, "second": 0}
onready var ingame_time = {"hour": 21, "minute": 30, "second": 0}

onready var worldenv:WorldEnvironment = get_node_or_null("/root/world/Viewport/main/map/main_map/WorldEnvironment")
onready var main_menu_worldenv:WorldEnvironment = get_node_or_null("/root/main_menu/world/Viewport/main/map/main_map/WorldEnvironment")
onready var main_zone = get_node_or_null("/root/world/Viewport/main/map/main_map/zones/main_zone")

var LL_fireflies = preload("res://mods/LonelyLoner/Assets/Scenes/fireflies.tscn").instance()
var LL_campfire = preload("res://mods/LonelyLoner/Assets/Scenes/campfire.tscn").instance()

var des_color = null
var min_timer:Timer
var sec_timer:Timer
var in_game_sec_timer:Timer
var lh_timer:Timer
var mode = "IngameTime"
var check_lh = false
var ingame_second_length = 0.0000000001
var fireflies_bootstrapped = false
var worldenv_bootstrapped = false

func _ready():
	print(ID + " has loaded!")
	_startup()

func _startup():
	check_time()
	match mode:
		"RealTime":
			create_timer(min_timer, 60, "check_time") # Set the interval at which to poll irl time
			#create_timer(sec_timer, 1, "_poll_long_haul")
		"IngameTime":
			create_timer(min_timer, ingame_second_length, "check_time") # Set the interval at which to poll in game time
			#create_timer(sec_timer, 1, "_poll_long_haul")
			create_timer(in_game_sec_timer, ingame_second_length, "_in_game_time_has_passed")

func _cleanup():
	main_zone.disconnect("tree_exiting", self, "_cleanup")
	worldenv.disconnect("tree_exiting", self, "_cleanup")
	worldenv = null
	main_zone.remove_child(LL_fireflies)
	main_zone = null
	fireflies_bootstrapped = false
	worldenv_bootstrapped = false

func _node_scanner():
	if worldenv != null && is_instance_valid(worldenv) == true && worldenv_bootstrapped == false:
		worldenv_bootstrapped = true
		worldenv.connect("tree_exiting", self, "_cleanup")
	if worldenv != null && is_instance_valid(worldenv) == true:
		_set_color_by_time(worldenv)
	if main_menu_worldenv != null && is_instance_valid(main_menu_worldenv) == true:
		_set_color_by_time(main_menu_worldenv)
	#if is_instance_valid(fireflies) == false:
	#	fireflies = load("res://mods/LonelyLoner/Assets/Scenes/fireflies.tscn").instance()
	if main_zone != null && is_instance_valid(main_zone) == true && fireflies_bootstrapped == false:
		#print("Tried to add fireflies")
		fireflies_bootstrapped = true
		main_zone.add_child(LL_fireflies)
		main_zone.connect("tree_exiting", self, "_cleanup")
	else:
		worldenv = get_node_or_null("/root/world/Viewport/main/map/main_map/WorldEnvironment")
		main_menu_worldenv = get_node_or_null("/root/main_menu/world/Viewport/main/map/main_map/WorldEnvironment")
		main_zone = get_node_or_null("/root/world/Viewport/main/map/main_map/zones/main_zone")

func _physics_process(delta):
	_node_scanner()
	print(check_time())

func _set_color_by_time(env):
	var time = check_time()
	match time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			env.des_color = Color("#14253e")
		5, 6, 7:
			env.des_color = Color("#ffd6e7")
		17, 18, 19:
			env.des_color = Color ("#ffa370")
		8, 9, 10, 11, 12, 13, 14, 15, 16:
			env.des_color = Color("#d5eeff")
		_:
			env.des_color = Color("d5eeff")
			print(str(self) + ": WHERE ARE YOU?!?! (could not set time by hour because hour is either overflowed or doesn't exist)")

func create_timer(timer, wait_by, function):
	timer = Timer.new()
	timer.wait_time = wait_by
	add_child(timer)
	timer.connect("timeout", self, function)
	timer.start()
	return timer

func _in_game_time_has_passed():
	ingame_time["second"] = ingame_time["second"] + 1
	emit_signal("second_has_passed")
	if ingame_time["second"] >= 60:
		ingame_time["second"] = 0
		ingame_time["minute"] = ingame_time["minute"] + 1
		emit_signal("minute_has_passed")
	if ingame_time["minute"] >= 60:
		ingame_time["minute"] = 0
		ingame_time["hour"] = ingame_time["hour"] + 1
		emit_signal("hour_has_passed")
	if ingame_time["hour"] >= 24:
		ingame_time = {"hour": 0, "minute": 0, "second": 0}
		emit_signal("day_has_passed")

func check_time():
	match mode:
		"RealTime":
			real_time = Time.get_time_dict_from_system()
			#print(ID + ": " + str(real_time)) # Just for debug to make sure it be working
			return real_time
		"IngameTime":
			#print(ID + ": " + str(ingame_time)) # Just for debug to make sure it be working
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

