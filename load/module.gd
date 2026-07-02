extends RefCounted
## 批量预加载 + 进度扩展。
## 复制整个 [code]load/[/code] 到 [code]ext/[/code]，Dock [b]扩展管理 → 生成扩展 API[/b] 后使用 [code]GDFrame.load_*[/code]。
const _SERVICE: Script = preload("load_service.gd")


static func register(gdframe: Node) -> void:
	var svc: Node = _SERVICE.new()
	svc.name = "GDFrameLoadService"
	gdframe.add_child(svc)
	svc.call("setup", gdframe)
	gdframe.service_register(&"load", svc)
