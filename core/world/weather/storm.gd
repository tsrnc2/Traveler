extends Light2D

var IS_STORM := false setget set_storm_state
export(float) var Flash_Percent := 0.05 #percent chance of lightning flash

onready var tween : Tween = $Tween

var flash_pattern : Array

var tween_error :bool = true setget on_tween_error

func _ready()->void:
	visible = false

func on_tween_error(new_error:bool)->void:
	tween_error = new_error
	if tween_error != true:
		print("Error in Lightning :", tween_error )

func initialize(_is_storm :bool = false) -> void:
	self.IS_STORM = _is_storm
	make_flash_pattern()

func make_flash_pattern() -> void:
	randomize()
	flash_pattern.append(false)
# warning-ignore:unused_variable
	for i in range(10): # get random array of bools
		flash_pattern.append( (randf()>0.7) )
	flash_pattern.append(false)

func set_storm_state(_is_storm :bool) -> void:
	if _is_storm == IS_STORM:
		return
	IS_STORM = _is_storm
	if _is_storm:
		start_storm()
	else:
		end_storm()

func flash_lightning() -> void:
	if randf() > Flash_Percent:
		for value in flash_pattern:
			visible = value
			self.tween_error = tween.interpolate_property(self,"energy",1,randi()%10, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN)
			self.tween_error = tween.start()
			yield(get_tree().create_timer(0.07), "timeout")
	_flash_done()

func _flash_done()->void:
	print("finished lightnig round")
	yield(get_tree().create_timer(12.0), "timeout")
	if IS_STORM:
		flash_lightning()

func end_storm()->void:
	visible = false

func start_storm()->void:
#	visible = true
	flash_lightning()
