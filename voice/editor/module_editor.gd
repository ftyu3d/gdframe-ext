extends RefCounted


static func facade_methods() -> Array[Dictionary]:
	return [
		{
			"signature": "func play_voice(stream: AudioStream, from_position: float = 0.0) -> void",
			"delegate": &"play_voice",
			"call_args": "stream, from_position",
		},
		{
			"signature": "func stop_voice() -> void",
			"delegate": &"stop_voice",
			"call_args": "",
		},
		{
			"signature": "func is_voice_playing() -> bool",
			"delegate": &"is_voice_playing",
			"call_args": "",
			"return_wrap": "bool",
		},
		{
			"signature": "func get_voice_stream() -> AudioStream",
			"delegate": &"get_voice_stream",
			"call_args": "",
			"return_wrap": "AudioStream",
		},
		{
			"signature": "func await_voice_finished() -> void",
			"await_service": &"voice",
			"delegate": &"await_voice_finished",
		},
	]
