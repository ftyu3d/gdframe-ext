# BGS 扩展（循环环境音）

单轨循环 **BGS**（Background Sound），走 **`BGS`** 音频总线，与 BGM / SFX 分离。

## API（`GDFrame`）

| 方法 | 说明 |
|------|------|
| `play_bgs(stream, from_position=0)` | 播放循环 BGS（同 stream 会按 `from_position` 重新起播） |
| `stop_bgs()` | 停止 |
| `is_bgs_playing()` | 是否在播 |
| `get_bgs_stream()` | 当前逻辑 stream |

## 行为说明

- **`GDFrame.audio_is_paused()` 为 true 时** 不启动新播（与 `audio_play_ui_sfx` 不同）
