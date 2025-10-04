extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -280.0

var attack_type: String
var using_dark_frame := true
var is_attacking := false
@onready var attacksound: AudioStreamPlayer2D = $attack
@onready var walkingsound: AudioStreamPlayer2D = $walking

var health = 200
var health_max = 200
var health_min = 0

var can_take_damage : bool
var dead: bool

@onready var dark_frame: AnimatedSprite2D = $"Dark-Frame"
@onready var light_frame: AnimatedSprite2D = $"Light-Frame"
@onready var deal_damage_zone = $"DealDamageZone"

@onready var anim_sprite: AnimatedSprite2D = $"Dark-Frame"

var respawn_point: Vector2 = Vector2.ZERO

func _ready() -> void:
	dark_frame.show()
	light_frame.hide()
	dead = false
	Global.playerAlive = true
	Global.playerStartingPosition = self.position
	can_take_damage = true

func _physics_process(delta: float) -> void:
	Global.playerDamageZone = deal_damage_zone
	Global.playerHitbox = $PlayerHitBox
	
	if(Input.is_action_just_pressed("Exit")):
		get_tree().change_scene_to_file("res://scenes/Main-Menu.tscn")
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# jumping
	if !dead:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# horizontal movement
		var direction = Input.get_axis("Move_left", "Move_right")
		Global.playerCurrentPosition = self.position
		if direction:
			
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		# walking sound
		if is_on_floor() and direction!=0 and not dead:
			if not walkingsound.playing:
				walkingsound.play()
		else:
			if walkingsound.playing:
				walkingsound.stop()
		# world switching
		if Input.is_action_just_pressed("Switch_World"):
			switch_frames()
		
		# attack handling
		if not is_attacking:
			if Input.is_action_just_pressed("Attack_1"):
				is_attacking = true
				attack_type = "Attack-1"
				handle_attack(attack_type)
			elif Input.is_action_just_pressed("Attack_2"):
				is_attacking = true
				attack_type = "Attack-2"
			set_damage(attack_type)
			handle_attack(attack_type)
		
		if not is_attacking:
			handle_movement_animation(direction)
		check_hitbox()
	move_and_slide()
	
func check_hitbox():
	var hitbox_areas = $PlayerHitBox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is BadNinja:
			damage = Global.NinjaDamageAmount
			
	if can_take_damage:
		take_damage(damage)
		
func take_damage(damage):
	if damage!=0:
		if health>0:
			health-=damage
			print(health)
			if health<=health_min:
				health=health_min
				dead= true
				Global.playerAlive = false 
				handle_dead_anim()
			take_damage_cooldown(1.0)
			
			
func handle_dead_anim():
	anim_sprite.play("Dead")
	await get_tree().create_timer(1).timeout
	die_and_respawn()
func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true
func set_damage(attack_type):
	var current_damage_to_deal : int
	if attack_type =="Attack-1":
		current_damage_to_deal = 10
	elif attack_type =="Attack-2":
		current_damage_to_deal = 20
		
	Global.playerDamageAmount = current_damage_to_deal
func handle_movement_animation(direction: float) -> void:
	if velocity == Vector2.ZERO:
		anim_sprite.play("Idle")
	else:
		anim_sprite.play("Walk")
		
	toggle_flip_dir(direction)

func handle_attack(attack_type):
	if is_attacking:
		var animation = str(attack_type)
		anim_sprite.play(animation)
		attacksound.play()
		toggle_damage_collisions(attack_type)
		
func toggle_damage_collisions(attack_type):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "Attack-1":
		wait_time = 0.4
	elif attack_type == "Attack-2":
		wait_time = 0.3
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func switch_frames() -> void:
	using_dark_frame = !using_dark_frame
	var old_flip = anim_sprite.flip_h
	
	if using_dark_frame:
		dark_frame.show()
		anim_sprite = dark_frame
		light_frame.hide()
	else:
		light_frame.show()
		anim_sprite = light_frame
		dark_frame.hide()
	
	# restore facing direction
	anim_sprite.flip_h = old_flip


func toggle_flip_dir(direction: float) -> void:
	if direction == 1:
		anim_sprite.flip_h = false
		deal_damage_zone.scale.x=1
	elif direction == -1:
		anim_sprite.flip_h = true
		deal_damage_zone.scale.x =-1


func die_and_respawn() -> void:
	dead = false
	Global.playerAlive = true
	global_position = Global.playerStartingPosition
	velocity = Vector2.ZERO

func _on_dark_frame_animation_finished() -> void:
	if anim_sprite.animation.begins_with("Attack"):
		is_attacking = false

func _on_light_frame_animation_finished() -> void:
	if anim_sprite.animation.begins_with("Attack"):
		is_attacking = false
