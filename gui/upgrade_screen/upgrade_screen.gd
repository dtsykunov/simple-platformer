extends Control

@export var oxygen_upgrade_button: BaseButton
@export var pickaxe_upgrade_button: BaseButton
@export var skip_button: Button
@export var money_amount_label: Label

@export var upgrade_container: Control
@export var upgrade_description: Label
@export var upgrade_price_label: Label

var action_done: bool = false

func _ready() -> void:
	oxygen_upgrade_button.disabled = not ResourceManager.can_buy_upgrade(ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN)
	pickaxe_upgrade_button.disabled = true
	oxygen_upgrade_button.pressed.connect(_on_oxygen_upgrade_button_pressed)
	oxygen_upgrade_button.mouse_entered.connect(_change_upgrade_container.bind(ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN))
	oxygen_upgrade_button.mouse_exited.connect(upgrade_container.hide)

	skip_button.pressed.connect(_on_skip_button_pressed)

	money_amount_label.text = str(ResourceManager.get_resource(ResourceManager.ResourceType.MONEY))

func _change_upgrade_container(upgrade_type: ResourceManager.UpgradeTypes) -> void:
	if upgrade_type == ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN:
		upgrade_description.text = "Max Oxygen +5"
	upgrade_price_label.text = str(ResourceManager.upgrades_prices[upgrade_type])
	upgrade_container.show()

func _on_oxygen_upgrade_button_pressed() -> void:
	if action_done: return
	action_done = true
	ResourceManager.buy_upgrade(ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN)
	Global.game_controller.start_game()

func _on_skip_button_pressed() -> void:
	if action_done: return
	action_done = true
	Global.game_controller.start_game()
