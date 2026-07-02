extends RefCounted


static func facade_methods() -> Array[Dictionary]:
	return [
		{
			"signature": "func play_bgs(stream: AudioStream, from_position: float = 0.0) -> void",
			"delegate": &"play_bgs",
			"call_args": "stream, from_position",
		},
		{
			"signature": "func stop_bgs() -> void",
			"delegate": &"stop_bgs",
			"call_args": "",
		},
		{
			"signature": "func is_bgs_playing() -> bool",
			"delegate": &"is_bgs_playing",
			"call_args": "",
			"return_wrap": "bool",
		},
		{
			"signature": "func get_bgs_stream() -> AudioStream",
			"delegate": &"get_bgs_stream",
			"call_args": "",
			"return_wrap": "AudioStream",
		},
	]
