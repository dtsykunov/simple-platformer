extends Resource
class_name ObjectEntry

@export var scene: PackedScene
@export var probability: float = 1.0

# -1 means no limit
const NO_MAX_LIMIT: int = -1
@export var gen_height_min: int = 0
@export var gen_height_max: int = NO_MAX_LIMIT
