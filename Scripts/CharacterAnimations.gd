extends AnimationPlayer

@export var cc: CharacterController
@export var sprite: Sprite2D

func _process(delta: float) -> void:
	if abs(cc.velocity.x) > cc.SPEED:
		play("Dash")
	elif cc.velocity.y < 0:
		play("Jump")
	elif cc.velocity.y > 0:
		play("Fall")
	elif abs(cc.velocity.x) > 0:
		play("Run")
	else:
		play("Idle")

	if cc.velocity.x > 0:
		sprite.flip_h = false
	elif cc.velocity.x < 0:
		sprite.flip_h = true
