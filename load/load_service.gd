extends Node
## 批量预加载编排：加权进度、阶段信号。
## 由 [code]ext/load/module.gd[/code] 注册为 [code]GDFrame.service_get(&"load")[/code]。
##
## [code]load_run()[/code] 返回值：
## - [code]load_add_callable[/code] 步骤主动返回的业务错误码（原样传出）；
## - UI / FSM 预加载失败 → [member GDFrameResult.ERR_LOAD_PRELOAD_FAILED]（同时 [code]push_error[/code]）；
## - 空计划、重入等 → [member GDFrameResult.OK]（仅 [code]push_error[/code] / [code]push_warning[/code]）。

signal load_progress(ratio: float, label: String)
signal load_stage_started(stage: String)
signal load_stage_finished(stage: String)
signal load_all_finished(error: StringName)

const DEFAULT_STAGE: String = "_default"

var _gdframe: Node = null
var _stage_weights: Dictionary = {}
var _stage_order: Array[String] = []
var _tasks: Array[Dictionary] = []
var _completed_weight: float = 0.0
var _total_weight: float = 0.0
var _current_label: String = ""
var _running: bool = false


func setup(gdframe: Node) -> void:
	_gdframe = gdframe


func load_reset() -> void:
	if _running:
		push_error("GDFrame Load: 运行中无法 load_reset")
		return
	_stage_weights.clear()
	_stage_order.clear()
	_tasks.clear()
	_completed_weight = 0.0
	_total_weight = 0.0
	_current_label = ""


func load_add_stage(stage_name: String, weight: float = 1.0) -> void:
	if _running:
		push_warning("GDFrame Load: 运行中忽略 load_add_stage")
		return
	var stage: String = _normalize_stage(stage_name)
	if weight <= 0.0:
		weight = 1.0
	_stage_weights[stage] = weight
	_append_stage_order(stage)


func load_add_preload_ui(ui_id: StringName, stage: String = "") -> void:
	if _running:
		push_warning("GDFrame Load: 运行中忽略 load_add_preload_ui")
		return
	_tasks.append({
		"kind": &"ui",
		"ui_id": ui_id,
		"stage": _ensure_stage(stage),
		"label": String(ui_id),
	})


func load_add_preload_fsm(machine_id: StringName, stage: String = "") -> void:
	if _running:
		push_warning("GDFrame Load: 运行中忽略 load_add_preload_fsm")
		return
	_tasks.append({
		"kind": &"fsm",
		"machine_id": machine_id,
		"stage": _ensure_stage(stage),
		"label": String(machine_id),
	})


func load_add_callable(fn: Callable, stage: String = "", label: String = "") -> void:
	if _running:
		push_warning("GDFrame Load: 运行中忽略 load_add_callable")
		return
	var resolved_label: String = label.strip_edges()
	if resolved_label.is_empty():
		resolved_label = "task_%d" % _tasks.size()
	_tasks.append({
		"kind": &"callable",
		"callable": fn,
		"stage": _ensure_stage(stage),
		"label": resolved_label,
	})


func load_is_running() -> bool:
	return _running


func load_get_progress() -> float:
	if _total_weight <= 0.0:
		return 0.0
	return clampf(_completed_weight / _total_weight, 0.0, 1.0)


func load_get_current_label() -> String:
	return _current_label


func load_run() -> StringName:
	if not _begin_run():
		return GDFrameResult.OK

	var err: StringName = await _run_pipeline()

	_running = false
	_broadcast_all_finished(err)
	return err


func _begin_run() -> bool:
	if _running:
		push_error("GDFrame Load: load_run 重入（已有管线在运行）")
		return false
	if _tasks.is_empty():
		push_error("GDFrame Load: load_run 未添加任何任务")
		return false
	_running = true
	_completed_weight = 0.0
	_total_weight = _compute_total_weight()
	_current_label = ""
	return true


func _normalize_stage(stage_name: String) -> String:
	var trimmed: String = stage_name.strip_edges()
	return DEFAULT_STAGE if trimmed.is_empty() else trimmed


func _append_stage_order(stage: String) -> void:
	if not _stage_order.has(stage):
		_stage_order.append(stage)


func _ensure_stage(stage: String) -> String:
	var resolved: String = _normalize_stage(stage)
	if not _stage_weights.has(resolved):
		_stage_weights[resolved] = 1.0
	_append_stage_order(resolved)
	return resolved


func _compute_total_weight() -> float:
	var stages_with_tasks: Dictionary = {}
	for task: Dictionary in _tasks:
		stages_with_tasks[task["stage"]] = true
	var total: float = 0.0
	for stage: String in _stage_order:
		if stages_with_tasks.has(stage):
			total += float(_stage_weights.get(stage, 1.0))
	for task: Dictionary in _tasks:
		var stage: String = task["stage"]
		if not _stage_order.has(stage):
			_append_stage_order(stage)
			total += float(_stage_weights.get(stage, 1.0))
	return maxf(total, 0.0001)


func _tasks_for_stage(stage: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for task: Dictionary in _tasks:
		if task["stage"] == stage:
			out.append(task)
	return out


func _run_pipeline() -> StringName:
	var stages_with_tasks: Dictionary = {}
	for task: Dictionary in _tasks:
		stages_with_tasks[task["stage"]] = true

	for stage: String in _stage_order:
		if not stages_with_tasks.has(stage):
			continue
		var stage_tasks: Array[Dictionary] = _tasks_for_stage(stage)
		if stage_tasks.is_empty():
			continue

		var stage_weight: float = float(_stage_weights.get(stage, 1.0))
		var task_weight: float = stage_weight / float(stage_tasks.size())

		_broadcast_stage_started(stage)

		for task: Dictionary in stage_tasks:
			_current_label = String(task.get("label", ""))
			_broadcast_progress(load_get_progress(), _current_label)

			var task_err: StringName = await _run_task(task)
			if GDFrameResult.is_error(task_err):
				_broadcast_stage_finished(stage)
				return task_err

			_completed_weight += task_weight
			_broadcast_progress(load_get_progress(), _current_label)

		_broadcast_stage_finished(stage)

	_current_label = ""
	_broadcast_progress(1.0, "")
	return GDFrameResult.OK


func _run_task(task: Dictionary) -> StringName:
	match task.get("kind", &""):
		&"ui":
			return await _run_ui_task(task)
		&"fsm":
			return _run_fsm_task(task)
		&"callable":
			var fn: Callable = task.get("callable", Callable()) as Callable
			return await _run_callable_task(fn)
		_:
			push_error(
				"GDFrame Load: 未知任务类型 %s" % String(task.get("kind", &""))
			)
	return GDFrameResult.OK


func _run_ui_task(task: Dictionary) -> StringName:
	var ui_id: StringName = task.get("ui_id", &"") as StringName
	await _gdframe.call("ui_preload", ui_id)
	if not bool(_gdframe.call("ui_is_preloaded", ui_id)):
		push_error("GDFrame Load: UI 预加载失败 %s" % ui_id)
		return GDFrameResult.ERR_LOAD_PRELOAD_FAILED
	return GDFrameResult.OK


func _run_fsm_task(task: Dictionary) -> StringName:
	var machine_id: StringName = task.get("machine_id", &"") as StringName
	if not bool(_gdframe.call("fsm_is_machine_loaded", machine_id)):
		_gdframe.call("fsm_preload", machine_id)
	if not bool(_gdframe.call("fsm_is_machine_loaded", machine_id)):
		push_error("GDFrame Load: FSM 预加载失败 %s" % machine_id)
		return GDFrameResult.ERR_LOAD_PRELOAD_FAILED
	return GDFrameResult.OK


func _run_callable_task(fn: Callable) -> StringName:
	var result: Variant = await fn.call()
	if result is StringName and GDFrameResult.is_error(result):
		return result
	return GDFrameResult.OK


func _broadcast_progress(ratio: float, label: String) -> void:
	load_progress.emit(ratio, label)
	_gdframe.signal_load_progress.emit(ratio, label)


func _broadcast_stage_started(stage: String) -> void:
	load_stage_started.emit(stage)
	_gdframe.signal_load_stage_started.emit(stage)


func _broadcast_stage_finished(stage: String) -> void:
	load_stage_finished.emit(stage)
	_gdframe.signal_load_stage_finished.emit(stage)


func _broadcast_all_finished(error: StringName) -> void:
	load_all_finished.emit(error)
	_gdframe.signal_load_all_finished.emit(error)
