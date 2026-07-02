# Load 扩展（批量预加载 + 进度）

声明 UI / FSM / 自定义步骤队列，带阶段权重与 0~1 进度。

## API（`GDFrame`）

| 方法 | 说明 |
|------|------|
| `load_reset()` | 清空阶段与任务队列 |
| `load_add_stage(stage_name, weight=1.0)` | 声明阶段；`weight` 为该阶段在总进度中的相对权重（省略或为 `≤0` 时按 `1.0`） |
| `load_add_preload_ui(ui_id, stage="")` | 追加 UI 预加载任务 |
| `load_add_preload_fsm(machine_id, stage="")` | 追加 FSM Registry 预加载 |
| `load_add_callable(fn, stage="", label="")` | 自定义步骤（可 `async`） |
| `await load_run()` | 执行队列；成功为 `GDFrameResult.OK` |
| `load_get_progress()` | 当前 0~1 进度 |
| `load_get_current_label()` | 当前步骤文案 |
| `load_is_running()` | 是否正在执行（`load_run` 进行中为 `true`） |

## 行为说明

**规划期 vs 执行期**：先 `load_reset` → 多次 `load_add_*` 组队列，再 `await load_run()`。仅在 **`load_run` 未返回前**（`load_is_running()` 为 `true`）算「运行中」。

| 时机 | `load_add_*` | `load_reset` |
|------|--------------|--------------|
| 规划期（未 `load_run` 或已结束） | 正常入队 | 正常清空 |
| 运行中（`await load_run()` 尚未返回） | **忽略**本次调用（`push_warning`） | **拒绝**（`push_error`，不清空） |

运行中不能改队列，是为避免进度权重与任务列表在执行途中被改乱。若需第二套加载流程，应等当前 `load_run` 结束后再 `load_reset` 并重新 `load_add_*`。

**阶段权重**：各阶段的 `weight` 只影响 `load_get_progress()` / `signal_load_progress` 的 0~1 分配，不是秒数。例如 `ui` 权重 `3.0`、`fsm` 权重 `1.0` 时，UI 阶段占进度条约 75%，FSM 约占 25%（同阶段内多个任务均分该阶段权重）。

## 返回值

- **`load_run()`** 执行 callable 步骤时，若步骤函数返回非空 **`StringName` 错误码**，则原样作为 `load_run` 结果（可用 `tr(String(err))` 提示玩家）。
- **UI / FSM 预加载失败**时返回 `GDFrameResult.ERR_LOAD_PRELOAD_FAILED`（同时 `push_error`）。
- **空计划、重入**等异常情况下 `load_run` 仍可能返回 `GDFrameResult.OK`（同时 `push_error` / `push_warning`，未执行管线）。

## 信号

在 **`GDFrame`** 上订阅：

- `signal_load_progress(ratio, label)`
- `signal_load_stage_started(stage)`
- `signal_load_stage_finished(stage)`
- `signal_load_all_finished(error)`

## 示例

```gdscript
func _ready() -> void:
	await GDFrame.ui_preload(GDFrameConstants.UI_LOADING)
	var loading: Control = GDFrame.ui_open(GDFrameConstants.UI_LOADING)
	GDFrame.signal_load_progress.connect(_on_load_progress)

	GDFrame.load_reset()
	GDFrame.load_add_stage("ui", 3.0)
	GDFrame.load_add_preload_ui(GDFrameConstants.UI_START, "ui")
	GDFrame.load_add_preload_ui(GDFrameConstants.UI_MENU, "ui")
	GDFrame.load_add_preload_fsm(GDFrameConstants.FSM_PLAYER, "fsm")
	GDFrame.load_add_callable(_check_saves, "", "saves")

	var err: StringName = await GDFrame.load_run()
	if not GDFrameResult.is_ok(err):
		show_tip(tr(String(err)))
		return

	await loading.fade_out_and_close()
	GDFrame.ui_open(GDFrameConstants.UI_START)


func _on_load_progress(ratio: float, label: String) -> void:
	pass


func _check_saves() -> StringName:
	return GDFrameResult.OK
```
