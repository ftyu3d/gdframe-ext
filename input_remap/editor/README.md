# Input Remap 扩展

玩法 action 改键的序列化、应用与 profile 持久化（`class_name GDFrameInputRemap`）。

## API（`GDFrameInputRemap`）

| 方法 | 说明 |
|------|------|
| `event_to_dict(event)` / `dict_to_event(data)` | `InputEvent` ↔ 可 JSON 化 Dictionary |
| `format_binding(data)` | 设置页显示文案（`InputEvent.as_text()`） |
| `snapshot_actions(actions)` | 从当前 `InputMap` 截取默认绑定 |
| `apply_bindings(remap)` | 仅覆盖 `remap` 内列出的 action |
| `apply_from_saved(defaults, remap, actions)` | 先 defaults 再用户覆盖 |
| `apply_from_profile(defaults, actions)` | 从 profile 读 `input_remap` 并应用 |
| `get_remap(prof)` / `set_remap(remap, prof, flush)` | 读写 profile |

## Profile

- 字段 **`input_remap`**（`Dictionary`）

## 行为说明

- 面向**玩法 action**；不含 UI 导航 action（`ui_accept`、`ui_cancel` 等）
- **无内置改键 UI**，须业务自行做设置页

## 接入示例

1. 定义白名单（例如 `jump`、`attack`）
2. 启动：`defaults = snapshot_actions(WHITELIST)` → `apply_from_profile(defaults, WHITELIST)`
3. 改键：循环读 `Input.parse_input_event`；过滤 `InputEventAction` / 鼠标移动；`event_to_dict` 写入临时 dict
4. 保存：`set_remap(updated, null, true)` + `apply_bindings(updated)`
5. 恢复默认：`set_remap({}, null, true)` + `apply_from_saved(defaults, {}, WHITELIST)`
