extends Area2D

onready var Lootbox_Inventory := $Inventory
onready var sprite := $Sprite

signal lootbox_in_range(node_reference)

var lootable := false
const Actor = preload("res://actors/Actor.gd")
var target : Node = null # Actor

func initialize(target_actor:Node) -> void:
	print(target_actor)
	target_actor.connect("pickup", self, "pickup_items")
#	if not target_actor is Actor:
#		return
	target = target_actor
	cull_loot()

func cull_loot() -> void:
	#pick a random item and trash all others
	var lootnumber := int(randi() % Lootbox_Inventory.get_num_items())
	var inventory_list = Lootbox_Inventory.get_items()
	var i := 0
	for item in inventory_list:
		if not i == lootnumber:
			Lootbox_Inventory.trash(item.name)
		i += 1

func _on_ItemBag_body_entered(body:Node) -> void:
	if body == target:
		lootable = true
		sprite.open_box()
		emit_signal('lootbox_in_range',self)

func _on_ItemBag_body_exited(body:Node) -> void:
	if body == target:
		lootable = false
		sprite.close_box()

func pickup_items(world_location:Vector2) -> void:
	print('Pickup')
	if not lootable:
		return
	print('Pickup and lootable')
	var inventory_list = Lootbox_Inventory.get_items()
	for item in inventory_list:
		target.get_inventory().add(item.name,item.anount)
		print("added to player invintory")
		print(item.name)
		Lootbox_Inventory.trash(item.name)
