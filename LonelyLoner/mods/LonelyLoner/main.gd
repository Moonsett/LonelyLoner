extends Node

signal second_has_passed
signal minute_has_passed
signal hour_has_passed
signal day_has_passed

const ID = "LonelyLoner"
const mod_ver = "0.2.0"
onready var real_time = {"hour": 0, "minute": 0, "second": 0}
onready var ingame_time = {"hour": 23, "minute": 30, "second": 0}

onready var worldenv:WorldEnvironment
onready var main_zone
onready var campfire

var LL_fireflies = preload("res://mods/LonelyLoner/Assets/Scenes/fireflies.tscn").instance()
var LL_campfire = preload("res://mods/LonelyLoner/Assets/Scenes/campfire.tscn").instance()
var LL_lighthouse = preload("res://mods/LonelyLoner/Assets/Scenes/lighthouse.tscn").instance()

var des_color = null
var check_time_timer:Timer
var set_color_timer:Timer
var sec_timer:Timer
var in_game_min_timer:Timer
var irl_second_timer:Timer
var irl_min_timer:Timer
var irl_hour_timer:Timer
var irl_day_timer:Timer
var lh_timer:Timer

var check_lh = false
var ingame_minute_length = 0.1

var LL_worldenv_loaded = false
var LL_fireflies_loaded = false
var LL_campfire_loaded = false
var LL_lighthouse_loaded = false


var config: Dictionary
var LL_config_default: Dictionary = {
	"world_env": true,
	"fireflies": true,
	"campfire": true,
	"lighthouse": true,
	"real_time": false,
	"force_time": 0,
	"debug": false,
	"config_ver": {"ver": mod_ver},
}

enum TimeMode {
	INGAMETIME,
	REALTIME,
}

onready var mode = TimeMode.INGAMETIME

onready var tb = get_node_or_null("/root/TackleBox")
onready var dn = get_node_or_null("/root/nubz4lif.daynightcycle")

func _init_config():
	var saved_config = tb.get_mod_config(ID)

	for key in LL_config_default.keys():
		if !saved_config.has(key):
			saved_config[key] = LL_config_default[key]

	config = saved_config

	_check_config()

	tb.set_mod_config(ID, config)
	tb.connect("mod_config_updated", self, "_on_config_update")

func _check_config():
	if dn != null:
		if config["debug"]: print(ID + ": DayAndNight detected, disabling world_env modifications.")
		config["world_env"] = false
	if (config["force_time"] > 4) || (config["force_time"] < 0):
		if config["debug"]: print(ID + ": force_time config option is not set correctly, resetting to 0.")
		config["force_time"] = 0

func _on_config_update(mod_id: String, new_config: Dictionary):
	if mod_id != ID:
		return

	config = new_config
	_check_config()


func get_config():
	return config

func _ready():
	print(ID + " has loaded!")
	if tb != null:
		_init_config()
	else: config = LL_config_default
	get_tree().connect("node_added", self, "_node_scanner")
	_startup()

func _startup():
	if config["force_time"] == 0:
		match mode:
			TimeMode.REALTIME:
				check_time()
				create_timer(check_time_timer, 60, "check_time") # Set the interval at which to poll irl time
				create_timer(irl_second_timer, 1, "_emit_second")
				create_timer(irl_min_timer, 60, "_emit_minute")
				create_timer(irl_hour_timer, 3600, "_emit_hour")
				create_timer(irl_day_timer, 86400, "_emit_day")
				#create_timer(sec_timer, 1, "_poll_long_haul")
			TimeMode.INGAMETIME:
				create_timer(check_time_timer, ingame_minute_length, "check_time") # Set the interval at which to poll in game time
				create_timer(set_color_timer, ingame_minute_length, "_set_color_by_time")
				#create_timer(sec_timer, 1, "_poll_long_haul")
				create_timer(in_game_min_timer, ingame_minute_length, "_in_game_time_has_passed")

func _emit_second():
	emit_signal("second_has_passed")

func _emit_minute():
	emit_signal("minute_has_passed")

func _emit_hour():
	emit_signal("hour_has_passed")

func _emit_day():
	emit_signal("day_has_passed")

func _cleanup():
	if is_instance_valid(worldenv):
		if (config["world_env"]):
			if config["debug"]: print(ID + ": Unloading " + str(worldenv))
			self.disconnect("hour_has_passed", self, "_set_color_by_time")
			LL_worldenv_loaded = false
			worldenv.disconnect("tree_exiting", self, "_cleanup")
			worldenv = null

	if is_instance_valid(main_zone):
		if config["debug"]: print(ID + ": Unloading " + str(main_zone))
		if (config["fireflies"]):
			main_zone.remove_child(LL_fireflies)
			LL_fireflies_loaded = false
		if (config["lighthouse"]):
			main_zone.remove_child(LL_lighthouse)
			LL_lighthouse_loaded = false
		main_zone.disconnect("tree_exiting", self, "_cleanup")
		main_zone = null
	_cleanup_campfire()

func _cleanup_campfire():
	if is_instance_valid(campfire):
		if (config["campfire"]):
			if config.debug: print(ID + ": Unloading " + str(campfire))
			campfire.remove_child(LL_campfire)
			LL_campfire_loaded = false
			campfire.disconnect("tree_exiting", self, "_cleanup")
			campfire = null

func _node_scanner(node: Node):
	match node.get_path():
		NodePath("/root/world/Viewport/main/map/main_map/WorldEnvironment"), NodePath("/root/main_menu/world/Viewport/main/map/main_map/WorldEnvironment"):
			if (config["world_env"]):
				self.connect("hour_has_passed", self, "_set_color_by_time")
				LL_worldenv_loaded = true
				if config["debug"]: print(ID + ": Correctly found worldenv: " + str(node))
				_set_color_by_time()
				node.connect("tree_exiting", self, "_cleanup")
				worldenv = node
		NodePath("/root/world/Viewport/main/map/main_map/zones/main_zone"), NodePath("/root/main_menu/world/Viewport/main/map/main_map/zones/main_zone"):
			if (config["fireflies"]):
				node.add_child(LL_fireflies)
				LL_fireflies_loaded = true
			if (config["lighthouse"]):
				node.add_child(LL_lighthouse)
				LL_lighthouse_loaded = true
			node.connect("tree_exiting", self, "_cleanup")
			main_zone = node
	if node.has_node("campfire_flame") && config["campfire"]:
		if config["debug"]: print(ID + ": Campfire was found, loading LL scene on top of it")
		node.add_child(LL_campfire)
		LL_campfire_loaded = true
		if config["debug"]: print(ID + ": Loaded LL_campfire overtop of campfire")
		node.connect("tree_exiting", self, "_cleanup_campfire")
		campfire = node

func _physics_process(delta):
	pass

func _set_color_by_time():
	if is_instance_valid(worldenv):
		var time = check_time()
		match time["hour"]:
			0, 1, 2, 3, 4, 20, 21, 22, 23, 24:
				#worldenv.des_color = Color("#14253e")
				worldenv.des_color = Color("#1c2c46")
			5, 6, 7:
				worldenv.des_color = Color("#ffd6e7")
			17, 18, 19:
				worldenv.des_color = Color ("#ffa370")
			8, 9, 10, 11, 12, 13, 14, 15, 16:
				worldenv.des_color = Color("#d5eeff")
			_:
				worldenv.des_color = Color("d5eeff")
				print(ID + " error: " + str(time) + str(self) + ": WHERE ARE YOU?!?! (could not set time by hour because hour is either overflowed or doesn't exist)")

func create_timer(timer, wait_by, function):
	timer = Timer.new()
	timer.wait_time = wait_by
	add_child(timer)
	timer.connect("timeout", self, function)
	timer.start()
	return timer

func _in_game_time_has_passed():
	ingame_time["minute"] = ingame_time["minute"] + 1
	_emit_minute()
	if ingame_time["minute"] >= 60:
		ingame_time["minute"] = 0
		ingame_time["hour"] = ingame_time["hour"] + 1
		_emit_hour()
	if ingame_time["hour"] >= 24:
		ingame_time = {"hour": 0, "minute": 0, "second": 0}
		_emit_day()

func check_time():
	match mode:
		TimeMode.REALTIME:
			real_time = Time.get_time_dict_from_system()
			#print(ID + ": " + str(real_time)) # Just for debug to make sure it be working
			return real_time
		TimeMode.INGAMETIME:
			#print(ID + ": " + str(ingame_time)) # Just for debug to make sure it be working
			return ingame_time

# checks every second to see if it should switch to polling at a set interval
func _poll_long_haul():
	if check_lh == true:
		match mode:
			TimeMode.REALTIME:
				if real_time["minute"] == 30 || 0:
					lh_timer = _create_long_haul_timer(lh_timer, 1800, "check_time")
			TimeMode.INGAMETIME:
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

