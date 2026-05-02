@tool
extends EditorPlugin

const LoggingLevel = ProgrammaticTheme._LoggingLevel
const Verbosity = ProgrammaticTheme.Verbosity


var _editor_file_system: EditorFileSystem


func _enter_tree() -> void:
	resource_saved.connect(on_resource_changed)
	
	_editor_file_system = EditorInterface.get_resource_filesystem()
	_editor_file_system.resources_reload.connect(_on_resources_reloaded)


func _exit_tree() -> void:
	if _editor_file_system:
		if _editor_file_system.resources_reload.is_connected(_on_resources_reloaded):
			_editor_file_system.resources_reload.disconnect(_on_resources_reloaded)
		_editor_file_system = null


func on_resource_changed(res: Resource):
	if res is not Script:
		return
	
	if not res.is_tool():
		return
	
	if not inherits_from_programmatic_theme(res):
		return
	
	var constants = res.get_script_constant_map()
	if not constants.get("UPDATE_ON_SAVE", false):
		return
	
	var verbosity = constants.get("VERBOSITY", Verbosity.NORMAL)
	_info("ProgrammaticTheme %s has changed." % [res.resource_path], verbosity)
	
	_debug("> Creating instance...", verbosity)
	var instance = res.new()
	
	_debug("> Generating theme...", verbosity)
	instance._run()


func _on_resources_reloaded(resources: PackedStringArray) -> void:
	for path: String in resources:
		if path.ends_with(".gd"):
			var script: Script = load(path)
			on_resource_changed(script)


func inherits_from_programmatic_theme(script: Script):
	if script.get_global_name() == "ProgrammaticTheme":
		return true
	
	script.is_tool()
	
	var base_class = script.get_base_script()
	if base_class == null:
		return false
	
	return inherits_from_programmatic_theme(base_class)


func _debug(message: String, verbosity: LoggingLevel):
	_log_raw(LoggingLevel.DEBUG, "[ThemeGen][Save Sync] " + message, verbosity)

func _info(message: String, verbosity: LoggingLevel):
	_log_raw(LoggingLevel.INFO, "[ThemeGen][Save Sync] " + message, verbosity)

func _log_raw(logging_level: LoggingLevel, message: String, verbosity: LoggingLevel):
	if logging_level <= verbosity:
		print(message)
