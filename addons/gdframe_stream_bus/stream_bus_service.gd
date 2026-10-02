extends Node
class_name GDFrameStreamBusService
## 可配置流总线：每轨一个 [GDFrameExtStreamService]。
## 挂在音频根上。[code]GDFrame.audio[/code] 持有引用，[code]play_bgs[/code] 等方法直接调用。

const NODE_NAME: StringName = &"GDFrameStreamBusService"


var _players: Dictionary[StringName, GDFrameExtStreamService] = {}


func setup(channel_names: PackedStringArray) -> void:
	for raw: String in channel_names:
		_ensure_channel(StringName(raw))


func get_channel_names() -> PackedStringArray:
	var out := PackedStringArray()
	for key: StringName in _players.keys():
		out.append(String(key))
	out.sort()
	return out


func has_channel(channel: StringName) -> bool:
	return _players.has(channel)


## 在指定轨播放。循环只作用于 Ogg / MP3 / WAV 副本，不改传入的资源。
func play(channel: StringName, stream: AudioStream, loop: bool = true, from_position: float = 0.0) -> void:
	var play_stream: AudioStream = stream.duplicate()
	GDFrameAudioManager.apply_stream_loop(play_stream, loop)
	_player(channel).play_stream(stream, play_stream, from_position)


func stop(channel: StringName) -> void:
	_player(channel).stop_stream()


func is_playing(channel: StringName) -> bool:
	return _player(channel).playing


func get_source_stream(channel: StringName) -> AudioStream:
	return _player(channel).get_source_stream()


func _player(channel: StringName) -> GDFrameExtStreamService:
	return _players.get(channel)


func _ensure_channel(channel: StringName) -> void:
	var player := GDFrameExtStreamService.new()
	player.name = "Stream_%s" % String(channel)
	player.init_bus(channel)
	add_child(player)
	_players[channel] = player
