extends RefCounted
## 流总线扩展：可配置 BGS / Voice 等轨；目录 [code]addons/gdframe_stream_bus/[/code]。


const _CHANNELS_CONFIG: Script = preload("res://addons/gdframe_stream_bus/channels_config.gd")


static func extra_bus_names() -> Array[StringName]:
	var out: Array[StringName] = []
	for name: String in _CHANNELS_CONFIG.load_names():
		out.append(StringName(name))
	return out


static func register(gdframe: GDFrameRoot) -> void:
	var svc := GDFrameStreamBusService.new()
	svc.name = GDFrameStreamBusService.NODE_NAME
	gdframe.audio.get_root().add_child(svc)
	svc.setup(_CHANNELS_CONFIG.load_names())
	gdframe.audio._stream_bus = svc
