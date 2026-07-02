extends RefCounted
## 手柄震动扩展模块：复制整个 [code]rumble/[/code] 到 [code]ext/[/code] 即可。
const _SERVICE: Script = preload("rumble_service.gd")


static func register(gdframe: Node) -> void:
	gdframe.service_register(&"rumble", _SERVICE.new())
