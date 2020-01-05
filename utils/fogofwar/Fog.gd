extends ColorRect

onready var StormAnimator := 	$StormAnimation

export(bool) var IS_STORM := false

func initialize(_is_storm :bool = IS_STORM) -> void:
	IS_STORM = _is_storm
	StormAnimator.connect('animation_finished',self,'flash_animation_finished')
	if IS_STORM:
		flash_lightning()

func flash_lightning() -> void:
	StormAnimator.play('Flash')
	
func flash_animation_finished() -> void:
	print(IS_STORM)
	if IS_STORM:
		flash_lightning()
