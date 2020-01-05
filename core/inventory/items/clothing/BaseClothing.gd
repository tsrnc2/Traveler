#warning-ignore-all:unused_class_variable
extends "res://core/inventory/items/Item.gd"

enum CLOTHING_TYPE { FOOTWEAR=0, PANTS, SHIRTS, GLOVES, HAT, SOCKS }
var CLOTH_TYPE :Dictionary= { 
	'WOOL' : preload("res://core/inventory/items/clothing/BASECLOTHTYPE_Wool.tscn"),
	'COTTON': preload("res://core/inventory/items/clothing/BASECLOTHTYPE_Cotton.tscn"),
	'NYLON': preload("res://core/inventory/items/clothing/BASECLOTHTYPE_Nylon.tscn")}
export(ITEM_TYPE) var type = ITEM_TYPE.CLOTHING 
export(CLOTHING_TYPE) var clothing_type : int
export(int) var COLD_PROTECTION := 20
export(int) var HEAT_PROTECTION := 20
export(int) var WET_RESISTANCE := 4
export(Dictionary) var MATTERIALS := {'COTTON':90, 'WOOL':10, 'NYLON':10}

var is_in_use := false
var wetness := 0.0

func use(user:Node) -> bool:
	if amount == 0:
		return false
	return _apply_effect(user)

func get_average_material()->Dictionary:
	var average_material: Dictionary = {
		'HEAT_PROTECTION' : 0,
		'HEAT_PROTECTION_WHEN_WET' : 0,
		'COLD_PROTECTION' : 0,
		'COLD_PROTECTION_WHEN_WET' : 0,
		'WETNESS_RESISTANCE' : 0, }
#	for material in MATTERIALS:
#		var material_percentage :int = MATTERIALS.get(material) / 100
#		var cloth_type :Dictionary = CLOTH_TYPE.get(material)
#		average_material['HEAT_PROTECTION'] += cloth_type.HEAT_PROTECTION * material_percentage
#		average_material['COLD_PROTECTION'] += cloth_type.COLD_PROTECTION * material_percentage
#		average_material['HEAT_PROTECTION_WHEN_WET'] += cloth_type.HEAT_PROTECTION_WHEN_WET * material_percentage
#		average_material['COLD_PROTECTION_WHEN_WET'] += cloth_type.COLD_PROTECTION_WHEN_WET * material_percentage
#		average_material['WET_RESISTANCE'] += cloth_type.WET_RESISTANCE * material_percentage
	return average_material

func _apply_effect(user:Node) -> bool:
	if user.is_in_group('player'):
		user.get_inventory().set_equipment(display_name)
		return true
	return false

func get_item_wet(percent:float)->void:
	print('BaseClothing wetting item')
	var material = get_average_material()
	wetness += percent - (material.WETNESS_RESISTANCE * 10)
