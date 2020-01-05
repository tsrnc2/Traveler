extends TextureProgress
var error :int= OK setget on_error

func on_error(new_error:int)->void:
	error = new_error
	if error != OK:
		print("error in MiniGame Meter :", error)
		
func initialize(sorce:Node) -> void:
	value = 0
	self.error = sorce.connect("new_suspision",self,"on_new_suspision")
	
func on_new_suspision(new_suspision:int)->void:
	value = new_suspision
