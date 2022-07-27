extends Area2D

export var team_name : String = 'default'

func _ready():
	rset('color', Color(0, 0, 0))


func _on_Zone_area_entered(area):
	if area.is_in_group('item'):
		if area.item_name == 'flag':
			#restart game here
			pass
			
