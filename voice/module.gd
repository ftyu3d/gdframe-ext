extends RefCounted
## 语音扩展模块：复制整个 [code]voice/[/code] 到 [code]ext/[/code] 即可。
const _SERVICE: Script = preload("voice_service.gd")


static func register(gdframe: Node) -> void:
	var voice: AudioStreamPlayer = AudioStreamPlayer.new()
	voice.set_script(_SERVICE)
	voice.name = String(_SERVICE.BUS_VOICE)
	GDFrame.audio_get_root().add_child(voice)
	gdframe.service_register(&"voice", voice)


static func extra_bus_names() -> Array[StringName]:
	return [_SERVICE.BUS_VOICE]
