class_name GDFrameInputRemap
extends RefCounted
## 玩法 action 改键工具：序列化 [InputEvent]、写入 [InputMap]、profile 持久化。
## 不含 UI 导航 action（[code]ui_accept[/code] 等）；改键页与 listen 流程由业务实现。


static func get_remap(prof: GDFrameProfileResource = null) -> Dictionary:
	var p: GDFrameProfileResource = _resolve_profile(prof)
	if p == null:
		return {}
	var raw: Variant = p.settings.get("input_remap")
	if raw is Dictionary:
		return (raw as Dictionary).duplicate(true)
	return {}


static func set_remap(bindings: Dictionary, prof: GDFrameProfileResource = null, flush: bool = false) -> void:
	var p: GDFrameProfileResource = _resolve_profile(prof)
	if p == null:
		return
	p.settings.set("input_remap", bindings.duplicate(true))
	if flush:
		var gf: Node = _gdframe_node()
		if gf != null:
			gf.call("save_flush")


static func snapshot_actions(actions: Array) -> Dictionary:
	var out: Dictionary = {}
	for raw: Variant in actions:
		var action: String = String(raw)
		if not InputMap.has_action(action):
			continue
		var events: Array = []
		for ev: InputEvent in InputMap.action_get_events(action):
			if ev is InputEventAction or ev is InputEventShortcut:
				continue
			var dict: Dictionary = event_to_dict(ev)
			if not dict.is_empty():
				events.append(dict)
		out[action] = events
	return out


static func apply_bindings(bindings: Dictionary) -> void:
	for raw_key: Variant in bindings.keys():
		var action: String = String(raw_key)
		if not InputMap.has_action(action):
			continue
		_clear_action(action)
		for dict: Dictionary in _event_dicts_from_value(bindings[raw_key]):
			var ev: InputEvent = dict_to_event(dict)
			if ev != null:
				InputMap.action_add_event(action, ev)


static func apply_from_saved(defaults: Dictionary, bindings: Dictionary, actions: Array = []) -> void:
	var scope: Array = actions if not actions.is_empty() else defaults.keys()
	for raw: Variant in scope:
		var action: String = String(raw)
		if not InputMap.has_action(action):
			continue
		_clear_action(action)
		var source: Variant = bindings.get(action, defaults.get(action, []))
		for dict: Dictionary in _event_dicts_from_value(source):
			var ev: InputEvent = dict_to_event(dict)
			if ev != null:
				InputMap.action_add_event(action, ev)


static func apply_from_profile(defaults: Dictionary, actions: Array = []) -> void:
	apply_from_saved(defaults, get_remap(), actions)


static func event_to_dict(event: InputEvent) -> Dictionary:
	if event == null:
		return {}
	if event is InputEventKey:
		var key_ev: InputEventKey = event as InputEventKey
		return {
			"type": &"key",
			"physical_keycode": key_ev.physical_keycode,
			"keycode": key_ev.keycode,
		}
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		return {
			"type": &"mouse_button",
			"button_index": mb.button_index,
		}
	if event is InputEventJoypadButton:
		var jb: InputEventJoypadButton = event as InputEventJoypadButton
		return {
			"type": &"joypad_button",
			"button_index": jb.button_index,
			"device": jb.device,
		}
	if event is InputEventJoypadMotion:
		var jm: InputEventJoypadMotion = event as InputEventJoypadMotion
		return {
			"type": &"joypad_motion",
			"axis": jm.axis,
			"axis_value": jm.axis_value,
			"device": jm.device,
		}
	return {}


static func dict_to_event(data: Variant) -> InputEvent:
	if data is Dictionary:
		return _dict_to_event(data as Dictionary)
	if data is Array and not (data as Array).is_empty():
		var first: Variant = (data as Array)[0]
		if first is Dictionary:
			return _dict_to_event(first as Dictionary)
	return null


static func format_binding(data: Variant) -> String:
	var ev: InputEvent = dict_to_event(data)
	if ev != null:
		return ev.as_text().strip_edges()
	return ""


static func _dict_to_event(data: Dictionary) -> InputEvent:
	var kind: StringName = data.get("type", &"")
	match kind:
		&"key":
			var ev: InputEventKey = InputEventKey.new()
			ev.physical_keycode = data.get("physical_keycode", KEY_NONE) as Key
			ev.keycode = data.get("keycode", KEY_NONE) as Key
			return ev
		&"mouse_button":
			var mb: InputEventMouseButton = InputEventMouseButton.new()
			mb.button_index = int(data.get("button_index", MOUSE_BUTTON_NONE)) as MouseButton
			return mb
		&"joypad_button":
			var jb: InputEventJoypadButton = InputEventJoypadButton.new()
			jb.button_index = int(data.get("button_index", JOY_BUTTON_INVALID)) as JoyButton
			jb.device = int(data.get("device", -1))
			return jb
		&"joypad_motion":
			var jm: InputEventJoypadMotion = InputEventJoypadMotion.new()
			jm.axis = int(data.get("axis", JOY_AXIS_INVALID)) as JoyAxis
			jm.axis_value = float(data.get("axis_value", 0.0))
			jm.device = int(data.get("device", -1))
			return jm
		_:
			push_error("GDFrame InputRemap: 未知绑定类型 type=%s" % kind)
			return null


static func _event_dicts_from_value(value: Variant) -> Array:
	var out: Array = []
	if value is Dictionary:
		out.append(value)
	elif value is Array:
		for item: Variant in value as Array:
			if item is Dictionary:
				out.append(item)
	return out


static func _clear_action(action: String) -> void:
	for ev: InputEvent in InputMap.action_get_events(action):
		InputMap.action_erase_event(action, ev)


static func _gdframe_node() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(
		NodePath("/root/" + String(GDFrameConfig.AUTOLOAD_NAME))
	)


static func _resolve_profile(prof: GDFrameProfileResource) -> GDFrameProfileResource:
	if prof != null:
		return prof
	var gf: Node = _gdframe_node()
	if gf == null:
		return null
	return gf.call("save_get_profile") as GDFrameProfileResource
