extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var different_ingame_used_time = Time.get_datetime_dict_from_system()
var i_have_to_use_two_new_variables_for_the_same_function_in_game_worldenv_because_i_couldnt_figure_out_how_to_make_the_variables_global_or_change_the_visibility_from_within_that_script_sorry = null

# Called when the node enters the scene tree for the first time.

func _set_visibility_by_time():
	match different_ingame_used_time["hour"]:
		0, 1, 2, 3, 4, 20, 21, 22, 23:
			visible = true
		5, 6, 7:
			visible = false
		17, 18, 19:
			visible = true
		8, 9, 10, 11, 12, 13, 14, 15, 16:
			visible = false
		_:
			visible = false

func _ready():
	visible = true
	_set_visibility_by_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	i_have_to_use_two_new_variables_for_the_same_function_in_game_worldenv_because_i_couldnt_figure_out_how_to_make_the_variables_global_or_change_the_visibility_from_within_that_script_sorry = Time.get_datetime_dict_from_system()
	if i_have_to_use_two_new_variables_for_the_same_function_in_game_worldenv_because_i_couldnt_figure_out_how_to_make_the_variables_global_or_change_the_visibility_from_within_that_script_sorry["hour"] != different_ingame_used_time["hour"]:
		different_ingame_used_time = i_have_to_use_two_new_variables_for_the_same_function_in_game_worldenv_because_i_couldnt_figure_out_how_to_make_the_variables_global_or_change_the_visibility_from_within_that_script_sorry
		_set_visibility_by_time()
