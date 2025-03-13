@tool
extends EditorPlugin

func _enable_plugin() -> void:
	resource_saved.connect(on_resource_changed)


func on_resource_changed(res: Resource):
	if res is not Script:
		return
	
	if not res.is_tool():
		return
	
	if not inherits_from_programmatic_theme(res):
		return
	
	var constants = res.get_script_constant_map()
	if not constants.get("HOT_RELOAD", false):
		return
	
	_log("ProgrammaticTheme %s has changed." % [res.resource_path])
	
	_log("> Creating instance...")
	var instance = res.new()
	
	_log("> Generating theme...")
	instance._run()


func inherits_from_programmatic_theme(script: Script):
	if script.get_global_name() == "ProgrammaticTheme":
		return true
	
	script.is_tool()
	
	var base_class = script.get_base_script()
	if base_class == null:
		return false
	
	return inherits_from_programmatic_theme(base_class)


func _log(message: String):
	print("[ThemeGen Hot Reload] ", message)
