extends GDFrameExtStreamService
## 角色语音 / 旁白（单次播放，走 Voice 总线；新语音打断上一条）。

const BUS_VOICE: StringName = &"Voice"


func _ready() -> void:
	init_bus(BUS_VOICE)


func play_voice(audio_stream: AudioStream, from_position: float = 0.0) -> void:
	if GDFrame.audio_is_paused():
		push_warning("GDFrame Voice: play_voice ignored while audio is paused.")
		return
	if playing:
		stop()
	_source_stream = audio_stream
	stream = audio_stream
	play(from_position)


func stop_voice() -> void:
	_clear_source()


func is_voice_playing() -> bool:
	return is_stream_playing()


func get_voice_stream() -> AudioStream:
	return get_source_stream()


func await_voice_finished() -> void:
	if not playing:
		return
	await finished
