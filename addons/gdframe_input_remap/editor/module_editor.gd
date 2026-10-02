extends RefCounted


static func profile_fields() -> Array[Dictionary]:
	return [
		{
			"name": "input_remap",
			"type": "Dictionary",
			"default": {},
			"comment": "输入 action 改键（addons/gdframe_input_remap/）。",
		},
	]
