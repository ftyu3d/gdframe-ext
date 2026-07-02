extends RefCounted
## BGS 扩展模块：复制整个 [code]bgs/[/code] 到 [code]ext/[/code] 即可。
const _SERVICE: Script = preload("bgs_service.gd")


static func register(gdframe: Node) -> void:
	var bgs: AudioStreamPlayer = AudioStreamPlayer.new()
	bgs.set_script(_SERVICE)
	bgs.name = String(_SERVICE.BUS_BGS)
	GDFrame.audio_get_root().add_child(bgs)
	gdframe.service_register(&"bgs", bgs)


static func extra_bus_names() -> Array[StringName]:
	return [_SERVICE.BUS_BGS]
