extends Node

@export var resources := {
	"money": 0,			#you can leave those blank this is just what you start with
	"oxygen": 10,
}

@export var label_container: NodePath

var resource_labels := {}

func _ready():
	for name in resources.keys():
		_create_or_update_label(name)

func add_resource(name: String, value: int):
	if name in resources:
		resources[name] += value
	else:
		resources[name] = value
	_create_or_update_label(name)

func _create_or_update_label(name: String) -> void:
	if not resource_labels.has(name):
		var label = Label.new()
		label.name = name + "_label"
		label.text = "%s: %d" % [name, resources[name]]
		resource_labels[name] = label
		if label_container:
			get_node(label_container).add_child(label)
	else:
		resource_labels[name].text = "%s: %d" % [name, resources[name]]
