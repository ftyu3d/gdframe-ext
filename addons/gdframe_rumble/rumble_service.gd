extends RefCounted
class_name GDFrameRumbleService
## 手柄震动：读写 profile，执行 [code]Input.start_joy_vibration[/code]。


func get_enabled() -> bool:
	return bool(_settings().get("rumble_enabled"))


func set_enabled(enabled: bool) -> void:
	_settings().set("rumble_enabled", enabled)


func default_enabled() -> bool:
	return true


func rumble(device: int = -1, weak: float = 0.35, strong: float = 0.55, duration: float = 0.12) -> void:
	if not get_enabled():
		return
	if device >= 0:
		Input.start_joy_vibration(device, weak, strong, duration)
		return
	for joy_id: int in Input.get_connected_joypads():
		Input.start_joy_vibration(joy_id, weak, strong, duration)


func _settings() -> GDFrameSettingsData:
	var prof: GDFrameProfileResource = GDFrame.save.get_profile()
	return prof.settings
