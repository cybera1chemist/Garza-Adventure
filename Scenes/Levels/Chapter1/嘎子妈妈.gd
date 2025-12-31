extends CharacterBody2D

@onready var dialog_ui: Control = $Dialog

@export_category("Dialog Groups Resources")
@export var dialog1: DialogGroup # 嘎子刚进门，没和外婆对话
@export var dialog2: DialogGroup # 嘎子和外婆对话完，和妈妈对话，妈妈询问是否进入战斗
@export var dialog3: DialogGroup # 触发这条对话说明即将进入战斗
@export var dialog4: DialogGroup # 战斗胜利后，和妈妈对话

func _ready():
	dialog_ui.set_dialog_group(dialog1)
