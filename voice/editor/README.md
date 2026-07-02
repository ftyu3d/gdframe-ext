# Voice 扩展（角色语音）

单轨 **语音**播放，走 **`Voice`** 音频总线；新语音会 **stop** 上一条（无排队/混音）。

## API（`GDFrame`）

| 方法 | 说明 |
|------|------|
| `play_voice(stream, from_position=0)` | 播放语音 |
| `stop_voice()` | 停止 |
| `is_voice_playing()` | 是否在播 |
| `get_voice_stream()` | 当前逻辑 stream |
| `await GDFrame.await_voice_finished()` | 等待当前条播完 |

## 行为说明

- **`GDFrame.audio_is_paused()` 为 true 时** 不启动新播
