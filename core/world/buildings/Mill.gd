extends Sprite
enum STATES { CLOSED, OPEN }
var _state = STATES.CLOSED

func open_door():
	$Door.play('Open')
	
func close_door():
	$Door.play('Close')

func _on_Seller_body_exited(body):
	if body.is_in_group("player"):
		_change_state(STATES.CLOSED)

func _on_Seller_body_entered(body):
	if body.is_in_group("player"):
		_change_state(STATES.OPEN)

func _on_Seller_shop_open_requested(shop, user):
	_change_state(STATES.OPEN)
	
func _change_state(new_state):
	if new_state == _state:
		return
	match new_state:
		STATES.OPEN:
			open_door()
		STATES.CLOSED:
			close_door()
	_state = new_state
