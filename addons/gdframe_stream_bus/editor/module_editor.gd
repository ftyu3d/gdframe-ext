extends RefCounted
## 流总线扩展 Dock 页签，以及 [code]GDFrame.audio[/code] 轨方法生成。


const _AUDIO_API_GEN: Script = preload("res://addons/gdframe_stream_bus/editor/audio_api_gen.gd")
const _CHANNELS_CONFIG: Script = preload("res://addons/gdframe_stream_bus/channels_config.gd")


static func generate_audio_channels() -> Dictionary:
	return _AUDIO_API_GEN.build(_CHANNELS_CONFIG.load_names())


static func dock_tab() -> Dictionary:
	return {
		"title": "流总线",
		"page": "res://addons/gdframe_stream_bus/editor/dock_page.gd",
	}
