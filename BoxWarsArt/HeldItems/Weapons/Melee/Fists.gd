extends Melee

var first_fist : bool = true

func attack_animation():
	if first_fist:
		$AnimationPlayer.play("Attack1")
	else:
		$AnimationPlayer.play("Attack2")
	first_fist = !first_fist
	#.attack_animation()
