extends Node2D

export var color : Color 
enum FLAG_STATE {CAPTURED, CAPTURING, IDLE}
export(FLAG_STATE) var currentState = FLAG_STATE.IDLE

var capturing_players = []
var timer = 1000


# Called when the node enters the scene tree for the first time.
func _ready():
	$Polygon2D.color = color
	
func _process(delta):
	match currentState:
		FLAG_STATE.IDLE:
#			if capturing_player == detect_oldest_player():
#				currentState = FLAG_STATE.CAPTURING
			if capturing_players.size() > 0:
				timer = 1000
				currentState = FLAG_STATE.CAPTURING
		FLAG_STATE.CAPTURING:
			timer -= 1
#			print('caputring')
#			if capturing_player != detect_oldest_player():
#				currentState = FLAG_STATE.IDLE
			print(timer)
			if timer == 0:
				currentState = FLAG_STATE.CAPTURED
				
			if capturing_players.size() == 0:
				currentState = FLAG_STATE.IDLE
		FLAG_STATE.CAPTURED:
			print('captured')

func _on_Area2D_body_exited(body):
	if body.is_in_group('player'):
#		if body == capturing_player:
#			capturing_player = detect_oldest_player()
		capturing_players.append(body.name)
		
		if body.name == capturing_players[0]:
			currentState = FLAG_STATE.IDLE

func _on_Area2D_body_entered(body):
	if body.is_in_group('player'):
		#capturing_player = body
		capturing_players.erase(body.name)

func detect_oldest_player():
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group('player'):
			return body

func _on_CaptureTimer_timeout():
	print('captured')
