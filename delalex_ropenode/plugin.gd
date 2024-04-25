@tool
@icon("res://addons/delalex_ropenode/icon.svg")
extends EditorPlugin


func _enter_tree():
	add_custom_type('Rope', 'Marker3D', preload("rope.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type('Rope')
