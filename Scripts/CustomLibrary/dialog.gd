extends Resource
class_name Dialog

enum DialogType {
    SPEAK, ACTION
}

@export var type: DialogType = DialogType.SPEAK
@export var character_name: String
@export_multiline var content: String
@export var anim_name: String
