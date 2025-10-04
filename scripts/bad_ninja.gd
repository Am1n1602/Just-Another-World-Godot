extends CharacterBody2D

class_name BadNinja

const SPEED = 60
var is_Player_chase: bool = false

var health = 80
var health_max = 80
var health_min = 0

var dead: bool = false
@onready var attacksound: AudioStreamPlayer2D = $attacksound

var taking_damage: bool = false

var damage_done = 15

var kill_points = 150

var is_damaging: bool = false

var dir: Vector2
var knockback_force = -100
var is_roaming: bool = true

@onready var player:CharacterBody2D = get_tree().root.get_node("Game/Player")

var player_in_area = false

@onready var dark_frame: AnimatedSprite2D = $"Dark-Frame"
@onready var light_frame: AnimatedSprite2D = $"Light-Frame"
var using_dark_frame := true

func _ready() -> void:
	dark_frame.show()
	light_frame.hide()

func _process(delta):
	if !is_on_floor():
		velocity +=get_gravity()*delta
		
	if Global.playerAlive:
		is_Player_chase = true
	if !Global.playerAlive:
		is_Player_chase = false
		
	Global.NinjaDamageAmount = damage_done
	Global.NinjaDamageZone = $"NinjaDealdamagezone"
	move(delta)
	if(Input.is_action_just_pressed("Switch_World")):
		switch_frame()
	handle_animation()
	move_and_slide()
	
func switch_frame():
	using_dark_frame = !using_dark_frame
	if(using_dark_frame):
		dark_frame.show()
		light_frame.hide()
	else:
		dark_frame.hide()
		light_frame.show()

func move(delta):
	if !dead:
		if!is_Player_chase:
			velocity+=dir*SPEED*delta
		elif is_Player_chase and !taking_damage and Global.playerAlive:
			var dir_to_player = position.direction_to(player.position) * SPEED
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x)/velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position)*knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x=0

func handle_animation():
	var anim_sprite: AnimatedSprite2D
	if(using_dark_frame):
		anim_sprite = dark_frame
	else:
		anim_sprite = light_frame
	if !dead and !taking_damage and !is_damaging:
		anim_sprite.play("Walk")
		if dir.x==-1:
			anim_sprite.flip_h = true
		elif dir.x==1:
			anim_sprite.flip_h = false
	elif  !dead and taking_damage and !is_damaging:
		anim_sprite.play("Hit")
		await get_tree().create_timer(0.4).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("Dead")
		await get_tree().create_timer(1).timeout
		handle_dead()
	elif !dead and is_damaging:
		anim_sprite.play("Attack-2")
		attacksound.play()
		await get_tree().create_timer(0.3).timeout

func handle_dead():
	Global.current_score += kill_points
	print(Global.current_score)
	self.queue_free()

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5,1.0,1.5])
	if !is_Player_chase:
		dir = choose([Vector2.RIGHT,Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()


func _on_ninja_hitbox_area_entered(area: Area2D) -> void:
	var damage = Global.playerDamageAmount
	if area==Global.playerDamageZone:
		take_damage(damage)
		
		
func take_damage(damage):
	health-=damage
	taking_damage = true
	if(health<=health_min):
		health=health_min
		dead=true
		
	


func _on_ninja_dealdamagezone_area_entered(area: Area2D) -> void:
	if area==Global.playerHitbox:
		is_damaging = true
		await get_tree().create_timer(0.3).timeout
		is_damaging = false
