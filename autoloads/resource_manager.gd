extends Node


signal resources_changed
signal oxygen_depleted

enum ResourceType {
	MONEY,
	OXYGEN,
	GOAL,
}

enum UpgradeTypes {
	ADD_MAX_OXYGEN,
}

const UPGRADE_PRICE_MULTIPLIER: int = 2
const DEFAULT_MAX_OXYGEN: int = 20

@export var default_resources: Dictionary[ResourceType, int] = {
	ResourceType.MONEY: 0, # you can leave those blank this is just what you start with
	ResourceType.OXYGEN: DEFAULT_MAX_OXYGEN,
	ResourceType.GOAL: 1,
}

@export var default_upgrades_levels: Dictionary[UpgradeTypes, int] = {
	UpgradeTypes.ADD_MAX_OXYGEN: 0,
}

@export var default_upgrades_prices: Dictionary[UpgradeTypes, int] = {
	UpgradeTypes.ADD_MAX_OXYGEN: 1,
}

var max_oxygen: int = DEFAULT_MAX_OXYGEN
var resources: Dictionary[ResourceType, int] = {}
var upgrades_levels: Dictionary[ResourceType, int] = {}
var upgrades_prices: Dictionary[ResourceType, int] = {}


func _ready() -> void:
	reset()


func add_resource(resource_type: ResourceType, value: int) -> void:
	if not resources.has(resource_type):
		set_resource_value(resource_type, value)
		return

	var new_value = resources[resource_type] + value
	if resource_type == ResourceType.OXYGEN:
		new_value = clamp(new_value, 0, max_oxygen)
		set_resource_value(resource_type, new_value)
		if new_value <= 0:
			oxygen_depleted.emit()
		return

	set_resource_value(resource_type, new_value)


func set_resource_value(resource_type: ResourceType, value: int):
	resources[resource_type] = value
	resources_changed.emit()


func is_goal_reached() -> bool:
	return resources[ResourceType.MONEY] >= resources[ResourceType.GOAL]

func renew() -> void:
	set_resource_value(ResourceType.OXYGEN, max_oxygen)

func check_goal_and_prepare() -> bool:
	var goal = resources[ResourceType.GOAL]
	if resources[ResourceType.MONEY] >= goal:
		add_resource(ResourceType.GOAL, 1)
		add_resource(ResourceType.MONEY, -goal)
		return true
	return false

func buy_upgrade(upgrade_type: UpgradeTypes) -> void:
	if not can_buy_upgrade(upgrade_type):
		return
	var price = upgrades_prices[upgrade_type]
	add_resource(ResourceType.MONEY, -price)
	upgrades_levels[upgrade_type] += 1
	upgrades_prices[upgrade_type] *= UPGRADE_PRICE_MULTIPLIER
	_apply_upgrades(upgrade_type)


func reset() -> void:
	max_oxygen = DEFAULT_MAX_OXYGEN
	resources = default_resources.duplicate()
	upgrades_levels = default_upgrades_levels.duplicate()
	upgrades_prices = default_upgrades_prices.duplicate()


func can_buy_upgrade(upgrade_type: UpgradeTypes) -> bool:
	if not upgrades_prices.has(upgrade_type):
		return false
	var price = upgrades_prices[upgrade_type]
	return resources[ResourceType.MONEY] >= price


func _apply_upgrades(upgrade_type: UpgradeTypes):
	if upgrade_type == UpgradeTypes.ADD_MAX_OXYGEN:
		max_oxygen += 5
