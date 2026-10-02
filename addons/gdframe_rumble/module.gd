extends RefCounted
## 手柄震动扩展模块：插件目录 [code]addons/gdframe_rumble/[/code]。


static func register(gdframe: GDFrameRoot) -> void:
	gdframe.ext_register(&"rumble", GDFrameRumbleService.new())
