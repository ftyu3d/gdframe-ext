@tool
extends RefCounted
## 流总线轨名配置（运行时与 Dock 共用）。
## 落盘路径：[member CHANNELS_CFG_PATH]。


const CHANNELS_CFG_PATH: String = "res://gdframe_project/generated/stream_bus_channels.cfg"
const _SECTION: String = "channels"
const _KEY: String = "names"
const DEFAULT_NAMES: PackedStringArray = ["BGS", "Voice"]

static var _name_re: RegEx


static func load_names() -> PackedStringArray:
	var raw: Variant = _read_names_value()
	if raw is PackedStringArray:
		return _sanitize_names(raw as PackedStringArray)
	return DEFAULT_NAMES.duplicate()


static func _read_names_value() -> Variant:
	var cfg := ConfigFile.new()
	if cfg.load(CHANNELS_CFG_PATH) != OK:
		return null
	return cfg.get_value(_SECTION, _KEY, DEFAULT_NAMES)


static func save_names(names: PackedStringArray) -> Error:
	var clean: PackedStringArray = _sanitize_names(names)
	var dir_path: String = CHANNELS_CFG_PATH.get_base_dir()
	var dir_err: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		return dir_err
	var cfg := ConfigFile.new()
	cfg.set_value(_SECTION, _KEY, clean)
	return cfg.save(CHANNELS_CFG_PATH)


static func is_valid_channel_name(raw: String) -> bool:
	var s: String = raw.strip_edges()
	if s.is_empty():
		return false
	if _name_re == null:
		_name_re = RegEx.new()
		_name_re.compile("^[A-Za-z_][A-Za-z0-9_]*$")
	return _name_re.search(s) != null


static func _sanitize_names(names: PackedStringArray) -> PackedStringArray:
	var seen: Dictionary[String, bool] = {}
	var out := PackedStringArray()
	for raw: String in names:
		var s: String = raw.strip_edges()
		if not is_valid_channel_name(s):
			continue
		if seen.has(s):
			continue
		seen[s] = true
		out.append(s)
	return out
