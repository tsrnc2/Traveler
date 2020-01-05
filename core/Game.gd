extends Node

onready var level_loader = $LevelLoader
onready var transition = $Overlays/TransitionColor
onready var pause_menu = $Interface/PauseLayer/PauseMenu
onready var tree = get_tree()

var error :int = OK setget on_error

func on_error(new_error:int) -> void:
	new_error = error
	if error != OK:
		print("Error in Game :", error)

func _ready()->void:
	print("Loading Traverler")
	print("Version :", ProjectSettings.get_setting("application/config/version"))
	$Interface.initialize($LevelLoader/Player)
	$Minigames.initialize($LevelLoader/Player)
	level_loader.initialize()
	for door in level_loader.get_doors():
		self.error = door.connect("player_entered", self, "_on_Door_player_entered")

func change_level(scene_path:PackedScene)->void:
	tree.paused = true
	yield(transition.fade_to_color(), "completed")
	level_loader.change_level(scene_path)
	for door in level_loader.get_doors():
		self.error = door.connect("player_entered", self, "_on_Door_player_entered")
	yield(transition.fade_from_color(), "completed")
	tree.paused = false

func _on_Door_player_entered(target_map:PackedScene)->void:
	change_level(target_map)

func _unhandled_input(event:InputEvent)->void:
	if event.is_action_pressed("pause"):
		pause()
		tree.set_input_as_handled()
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

func pause()->void:
	tree.paused = true
	pause_menu.open()
	yield(pause_menu, "closed")
	tree.paused = false

func _on_ShopMenu_open()->void:
	tree.paused = true

func _on_ShopMenu_closed()->void:
	tree.paused = false
