extends RefCounted


static func ext_service_type() -> String:
	return "GDFrameRumbleService"


static func profile_fields() -> Array[Dictionary]:
	return [
		{
			"name": "rumble_enabled",
			"type": "bool",
			"default": true,
			"comment": "是否启用手柄震动（addons/gdframe_rumble）。",
		},
	]
