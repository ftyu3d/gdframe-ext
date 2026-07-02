# Rumble 扩展（手柄震动）

读写 profile 中的 **`rumble_enabled`**，并调用 `Input.start_joy_vibration`。

## API（`GDFrame`）

| 方法 | 说明 |
|------|------|
| `rumble(device=-1, weak, strong, duration)` | 震动；`device=-1` 时对所有已连接手柄 |
| `get_rumble_enabled()` / `set_rumble_enabled(enabled)` | 读写开关（内存；持久化需 `save_flush`） |
| `default_rumble_enabled()` | 默认 `true` |

## Profile

- 字段 **`rumble_enabled`**（`bool`）

## 行为说明

- `rumble()` 在 `get_rumble_enabled()` 为 `false` 时不振动
- `set_rumble_enabled` 只改内存；设置页保存时调用 `save_flush()`
- `get_rumble_enabled()` 缺字段时等同 `default_rumble_enabled()`（`true`）
