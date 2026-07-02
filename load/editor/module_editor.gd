extends RefCounted


static func facade_methods() -> Array[Dictionary]:
	return [
		{
			"signature": "func load_reset() -> void",
			"delegate": &"load_reset",
			"call_args": "",
		},
		{
			"signature": "func load_add_stage(stage_name: String, weight: float = 1.0) -> void",
			"delegate": &"load_add_stage",
			"call_args": "stage_name, weight",
		},
		{
			"signature": "func load_add_preload_ui(ui_id: StringName, stage: String = \"\") -> void",
			"delegate": &"load_add_preload_ui",
			"call_args": "ui_id, stage",
		},
		{
			"signature": "func load_add_preload_fsm(machine_id: StringName, stage: String = \"\") -> void",
			"delegate": &"load_add_preload_fsm",
			"call_args": "machine_id, stage",
		},
		{
			"signature": "func load_add_callable(fn: Callable, stage: String = \"\", label: String = \"\") -> void",
			"delegate": &"load_add_callable",
			"call_args": "fn, stage, label",
		},
		{
			"signature": "func load_run() -> StringName",
			"delegate": &"load_run",
			"await_service": &"load",
			"return_wrap": "StringName",
		},
		{
			"signature": "func load_get_progress() -> float",
			"delegate": &"load_get_progress",
			"call_args": "",
			"return_wrap": "float",
		},
		{
			"signature": "func load_get_current_label() -> String",
			"delegate": &"load_get_current_label",
			"call_args": "",
			"return_wrap": "String",
		},
		{
			"signature": "func load_is_running() -> bool",
			"delegate": &"load_is_running",
			"call_args": "",
			"return_wrap": "bool",
		},
	]


static func result_constants() -> Array[String]:
	return ["ERR_LOAD_PRELOAD_FAILED"]


static func global_signals() -> Array[String]:
	return [
		"signal signal_load_progress(ratio: float, label: String)",
		"signal signal_load_stage_started(stage: String)",
		"signal signal_load_stage_finished(stage: String)",
		"signal signal_load_all_finished(error: StringName)",
	]
