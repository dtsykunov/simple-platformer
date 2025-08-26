extends Control

@export var oxygen_upgrade_button: Button
@export var skip_button: Button
@export var oxygen_upgrade_price_label: Label

func _ready() -> void:
	oxygen_upgrade_button.disabled = not ResourceManager.can_buy_upgrade(ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN)
	oxygen_upgrade_price_label.text = str(ResourceManager.upgrades_prices[ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN])

	oxygen_upgrade_button.pressed.connect(_on_oxygen_upgrade_button_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)

func _on_oxygen_upgrade_button_pressed() -> void:
	ResourceManager.buy_upgrade(ResourceManager.UpgradeTypes.ADD_MAX_OXYGEN)
	Global.game_controller.start_game()

func _on_skip_button_pressed() -> void:
	Global.game_controller.start_game()
