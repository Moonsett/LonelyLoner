extends WorldEnvironment

### Get OS time every 15 minutes, then check time range to see what color des_color should be
### Figure out a way to do algebraic math on hex colors, maybe convert them to vectors and do math on those?
### Maybe figure out good ambient lighting, too, idk (#ffa370 Sunset, #1a1426 Night, #d5eeff Day)



var des_fog = 125
var des_fog_end = 500
var des_color = Color("#ffa370")
var des_light = 0.1
var rain = false
var ingame_used_time = Time.get_datetime_dict_from_system()
var current_os_time = null

var default_fog = 125
var default_fog_end = 500

func _set_color_by_time():
	match ingame_used_time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			des_color = Color("#14253e")
		5, 6, 7:
			des_color = Color("#ffd6e7")
		17, 18, 19:
			des_color = Color ("#ffa370")
		8, 9, 10, 11, 12, 13, 14, 15, 16:
			des_color = Color("#d5eeff")
		_:
			des_color = Color("d5eeff")

func _ready():
	PlayerData.connect("_rain_toggle", self, "_rain_env")
	OptionsMenu.connect("_options_update", self, "_dist_update")
	_dist_update()
	_set_color_by_time()

func _check_time_deviation():
	var current_os_time = Time.get_datetime_dict_from_system()
	if current_os_time["hour"] != ingame_used_time["hour"]:
		ingame_used_time = Time.get_datetime_dict_from_system()
		_set_color_by_time()

func _physics_process(delta):
	var lerp_val = 0.01
	
	environment.fog_depth_begin = lerp(environment.fog_depth_begin, des_fog, lerp_val)
	environment.fog_depth_end = lerp(environment.fog_depth_end, des_fog_end, lerp_val)
	
	environment.background_color = lerp(environment.background_color, des_color, lerp_val)
	environment.ambient_light_color = lerp(environment.ambient_light_color, des_color, lerp_val)
	environment.fog_color = lerp(environment.fog_color, des_color, lerp_val)
	
	_check_time_deviation()
	
	$DirectionalLight.light_energy = lerp($DirectionalLight.light_energy, des_light, lerp_val)

func _rain_env(toggle, force = false):
	if toggle == rain and not force: return 
	rain = toggle
	
	if toggle:
		des_fog = 25
		des_fog_end = 75
		des_color = Color("#778688")
		des_light = 0.06
	
	else:

		_set_color_by_time()
		des_fog = default_fog
		des_fog_end = default_fog_end
		des_light = 0.1

func _dist_update():
	default_fog = [125, 50, 15, 6][PlayerData.player_options.view_distance]
	default_fog_end = [500, 200, 75, 12][PlayerData.player_options.view_distance]
	_rain_env(rain, true)
