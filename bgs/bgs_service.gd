extends GDFrameExtStreamService
## 循环环境音（BGS），走 BGS 总线。

const BUS_BGS: StringName = &"BGS"


func _ready() -> void:
	init_bus(BUS_BGS)


func play_bgs(audio_stream: AudioStream, from_position: float = 0.0) -> void:
	if GDFrame.audio_is_paused():
		push_warning("GDFrame BGS: play_bgs ignored while audio is paused.")
		return
	_source_stream = audio_stream
	stream = GDFrameAudioManager.with_loop(audio_stream)
	play(from_position)


func stop_bgs() -> void:
	_clear_source()


func is_bgs_playing() -> bool:
	return is_stream_playing()


func get_bgs_stream() -> AudioStream:
	return get_source_stream()
