# Rumble 扩展（手柄震动）

读写 profile 中的 **`rumble_enabled`**，并调用 `Input.start_joy_vibration`。

## API（`GDFrame.rumble`）

| 方法 | 说明 |
|------|------|
| `GDFrame.rumble.rumble(device=-1, weak, strong, duration)` | 震动；`device=-1` 时对所有已连接手柄 |
| `GDFrame.rumble.get_enabled()` / `GDFrame.rumble.set_enabled(enabled)` | 读写开关（内存；持久化需 `GDFrame.save.flush`） |
| `GDFrame.rumble.default_enabled()` | 默认 `true` |

## Profile

- 字段 **`rumble_enabled`**（`bool`）

## 行为说明

- `rumble()` 在 `get_enabled()` 为 `false` 时不振动
- `set_enabled` 只改内存；设置页保存时调用 `GDFrame.save.flush()`
- `get_enabled()` 缺字段时等同 `default_enabled()`（`true`）
