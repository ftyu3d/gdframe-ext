extends RefCounted


static func profile_fields() -> Array[Dictionary]:
	return [
		{
			"name": "rumble_enabled",
			"type": "bool",
			"default": true,
			"comment": "是否启用手柄震动（ext/rumble/）。",
		},
	]


static func facade_methods() -> Array[Dictionary]:
	return [
		{
			"signature": "func rumble(device: int = -1, weak: float = 0.35, strong: float = 0.55, duration: float = 0.12) -> void",
			"delegate": &"rumble",
			"call_args": "device, weak, strong, duration",
		},
		{
			"signature": "func get_rumble_enabled() -> bool",
			"delegate": &"get_rumble_enabled",
			"call_args": "",
			"return_wrap": "bool",
		},
		{
			"signature": "func set_rumble_enabled(enabled: bool) -> void",
			"delegate": &"set_rumble_enabled",
			"call_args": "enabled",
		},
		{
			"signature": "func default_rumble_enabled() -> bool",
			"delegate": &"default_rumble_enabled",
			"call_args": "",
			"return_wrap": "bool",
		},
	]
