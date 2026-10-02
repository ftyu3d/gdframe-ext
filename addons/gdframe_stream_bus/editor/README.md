# GDFrame Stream Bus

可配置流总线扩展：默认示例轨 **BGS**、**Voice**（可在 Dock「流总线」页增删）。

## 启用

1. 项目 → 项目设置 → 插件 → 启用 **GDFrame Stream Bus**
2. 底部面板 **GDFrame → 流总线** 增删轨后点 **生成**

**生成**把轨名写入 `res://gdframe_project/generated/stream_bus_channels.cfg`，并写出 `res://gdframe_project/generated/audio_channels.gd`。扩展管理 **生成扩展 API** 按已保存的轨名生成同一份方法；页上还没点 **生成** 的增删不会写入。卸掉本扩展后再次 **生成扩展 API**，`audio_channels.gd` 恢复为空壳（保留 `class_name GDFrameAudioChannels`）。

## 运行时

```gdscript
GDFrame.audio.play_bgs(stream)
GDFrame.audio.stop_bgs()
GDFrame.audio.is_voice_playing()
```

`register` 把服务挂到音频根，并把引用写到 `GDFrame.audio`。`play_*` 直接调用这份引用。播放实现在 `stream_bus_service.gd`，方法形态在 `editor/audio_api_gen.gd`。`module.extra_bus_names()` 根据配置声明总线；选项界面音频页会自动出现对应音量条。
