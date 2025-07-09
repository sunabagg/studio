@tool
extends EditorPlugin

var export_plugin : SbxExportPlugin

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	export_plugin = SbxExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
