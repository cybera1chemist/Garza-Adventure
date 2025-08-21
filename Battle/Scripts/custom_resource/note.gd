extends Resource
class_name Note

# If length == 0, then it's a short note;
# Otherwise it's a hold note.
@export var length: float = 0.0
@export var beat: float = 0.0
# trail should be 1~8
@export var trail: int = 1
