extends Node2D

@export var ninja_scene: PackedScene

var current_wave : int
var starting_nodes: int
var max_wave = 4
var current_nodes: int

var wave_ended

var player_in_wave_area = false

var start_time: float
var end_time: float
var total_time: float
var game_active = false
@onready var muzic: AudioStreamPlayer2D = $Muzic

func _ready() -> void:
	current_wave = 0
	Global.max_wave = max_wave
	muzic.play()
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	
	start_time = Time.get_ticks_msec()/1000.0
	game_active = true
	Global.game_active = true
	
func position_to_next_wave():
	if(current_wave>=max_wave and current_nodes==starting_nodes):
		Global.moving_to_next_move = false
		wave_ended = false
		end_time = Time.get_ticks_msec()/1000.0
		total_time = end_time - start_time
		update_score()
		print("Ended")
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://scenes/Main-Menu.tscn")
		return
	if !player_in_wave_area:
		return
	
	if current_nodes == starting_nodes:
		if current_wave!=1:
			Global.moving_to_next_move=true
			# can add scene fading transition
		wave_ended = false
		current_wave+=1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepare_spawn(1.5,1.0)
		
func prepare_spawn(multiplier,mob_spawns):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = 5.0
	var mob_spawn_rounds = mob_amount/mob_spawns 
	spawn_type(mob_spawn_rounds,mob_wait_time)
	
func spawn_type(mob_spawn_rounds,mob_wait_time):
	var EnemySpawn1=$EnemySpawn1
	var EnemySpawn2=$EnemySpawn2
	# later i will add more enemies 
	var EnemySpawn3=$EnemySpawn3
	var EnemySpawn4=$EnemySpawn4
	
	if(mob_spawn_rounds>=1):
		for i in mob_spawn_rounds:
			if(int(i)%2==0):
				var enemy1 = ninja_scene.instantiate()
				enemy1.global_position = EnemySpawn1.global_position
				add_child(enemy1)
			elif(int(i)%2==1):
				var enemy2 = ninja_scene.instantiate()
				enemy2.global_position = EnemySpawn2.global_position
				add_child(enemy2)
			mob_spawn_rounds -=1
			await get_tree().create_timer(mob_wait_time).timeout
		wave_ended = true


func _process(delta: float) -> void:
	current_nodes = get_child_count()
	
	if wave_ended and player_in_wave_area:
		position_to_next_wave()
		
func update_score():
	var time_bonus=0
	if total_time>0:
		time_bonus = int(max(0,(331-total_time)*13.14521))
		Global.current_score+=time_bonus
	Global.previous_score = Global.current_score
	if Global.current_score>Global.high_score:
		Global.high_score = Global.current_score
	Global.current_score = 0


func _on_wave_area_area_entered(area: Area2D) -> void:
	if !player_in_wave_area:
		player_in_wave_area = true
		position_to_next_wave()
		Global.show_wave_ui = true
