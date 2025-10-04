extends Node


var playerBody: CharacterBody2D
var playerDamageZone: Area2D
var playerDamageAmount: int
var playerAlive: bool
var NinjaDamageZone: Area2D
var NinjaDamageAmount: int
var playerHitbox: Area2D
var playerStartingPosition : Vector2
var current_wave: int
var moving_to_next_move: bool
var playerCurrentPosition: Vector2
var high_score : int
var current_score: int
var previous_score: int
var max_wave: int
var isAttacking: bool
var game_active=  false
var show_wave_ui = false
