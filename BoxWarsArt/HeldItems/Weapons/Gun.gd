extends Node2D

export (bool) var automatic = true
export (float) var fire_rate = 0.5
export (int) var magazine_size = 30
export (float) var reload_time = 1
export (int) var damage = 15
export (int) var bullet_speed = 40
# This is the least amount of random variance a bullet will have
export (float) var min_accuracy = 4
# this is the rate per SHOT that the weapon gets less accurate after firing
export (float) var accuracy_decrease = 1
# this is the rate per SECOND that the weapon becomes more accurate after the 
# weapon has stopped firing and the accuracy_increase_delay has completed
export (float) var accuracy_increase = 0.1
# this is the most amount of random variance a bullet will have
export (float) var max_accuracy = 10
# this is the delay before the accuracy increases again
export (float) var accuracy_increase_delay = 0.2
# procedural shotguns?????? This var might not work with current collision layers because bullets probably collide with themselves.
export (int, 1, 10) var bullet_per_shot = 1

const BULLET = preload("res://HeldItems/Weapons/Bullet/Bullet.tscn")

var can_fire := true
var current_magazine : int
var current_accuracy : float
var current_downtime : float = 0

# SET THIS VAR IN THING USING GUN, DETERMINES THE DIRECTION THE BULLET HEADS WHEN SHOT
var shoot_dir : Vector2 = Vector2(1, 1)
export var shoot_pos_path : NodePath
# SET THIS VAR IN THING USING GUN, DETERMINES WHERE THE BULLET IS INSTANCED
var shoot_pos : Position2D = null
var mock_gun_rotation : float = 0.0

onready var shot_timer : Timer = Timer.new()
onready var reload_timer : Timer = Timer.new()
#onready var player_ui = get_tree().get_nodes_in_group("PlayerUI")[0]

func _ready():
	add_to_group('gun')
	add_child(shot_timer)
	add_child(reload_timer)
	shot_timer.one_shot = true
	reload_timer.one_shot = true
	shot_timer.connect("timeout", self, "_on_ShotTimer_timeout")
	reload_timer.connect("timeout", self, "_on_ReloadTimer_timeout")
	if shoot_pos_path:
		shoot_pos = get_node(shoot_pos_path)
	#randomize()
	current_magazine = magazine_size
	current_accuracy = min_accuracy
#	player_ui.add_gun(magazine_size)
	#reload()

func _process(delta):
	mock_gun_rotation = int(rad2deg(atan2(shoot_dir.y, shoot_dir.x)))

	current_downtime += delta
	if current_downtime >= accuracy_increase_delay and current_accuracy != min_accuracy:
		current_accuracy = current_accuracy + -accuracy_increase * current_downtime
	current_accuracy = clamp(current_accuracy, min_accuracy, max_accuracy)

func reload():
	if reload_timer.is_stopped():
		$AnimationPlayer.play("Reloading")
		can_fire = false
	#	player_ui.reload_ammo(reload_time)
		reload_timer.start(reload_time)
	
func shoot(id : int, player_rotation : float, _name : String):
	if can_fire and current_magazine > 0:
		$AnimationPlayer.play("Shooting")
		current_downtime = 0
		can_fire = false
		shot_timer.start(fire_rate)
		update_magazine(current_magazine - 1)
		for shot in bullet_per_shot:
			var bullet_instance = BULLET.instance()
			#bullet_instance.damage = damage
			#bullet_instance.speed = bullet_speed
			var absolute_rotation = player_rotation + (rand_range(-current_accuracy, current_accuracy) / 100 * PI)
			var bullet_direction = Vector2(cos(absolute_rotation),sin(absolute_rotation))
			#bullet_instance.direction = bullet_direction
			if shoot_pos:
				bullet_instance.global_position = shoot_pos.global_position
			else:
				bullet_instance.global_position = global_position
			bullet_instance.name = _name
			get_tree().get_current_scene().add_child(bullet_instance)
			bullet_instance.initialize(bullet_speed, bullet_direction, damage)
			
		current_accuracy += accuracy_decrease

func _on_ReloadTimer_timeout():
	update_magazine(magazine_size)
	can_fire = true
	$AnimationPlayer.play("EndReloading")
	
func _on_ShotTimer_timeout():
	if reload_timer.is_stopped():
		can_fire = true

func update_magazine(amt : int):
	current_magazine = amt
#	player_ui.update_ammo(current_magazine)
