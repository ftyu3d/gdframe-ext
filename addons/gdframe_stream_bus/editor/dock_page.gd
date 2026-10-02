@tool
extends VBoxContainer
## GDFrame Dock「流总线」页：增删可配置轨（默认示例 BGS / Voice）。


const _CHANNELS_CONFIG: Script = preload("res://addons/gdframe_stream_bus/channels_config.gd")
const _AUDIO_API_GEN: Script = preload("res://addons/gdframe_stream_bus/editor/audio_api_gen.gd")

var _list: VBoxContainer
var _name_edit: LineEdit
var _status: Label
var _names: PackedStringArray = PackedStringArray()
var _row_stripe_boxes: Array = [null, null]


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	var add_row: HBoxContainer = HBoxContainer.new()
	add_row.add_theme_constant_override("separation", 6)
	add_child(add_row)
	var add_title: Label = Label.new()
	add_title.text = "新建轨"
	add_title.custom_minimum_size.x = 48
	add_row.add_child(add_title)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "轨名，如 Ambient"
	_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_edit.text_submitted.connect(func(_t: String) -> void: _on_add_pressed())
	add_row.add_child(_name_edit)
	var add_btn: Button = Button.new()
	add_btn.text = "添加"
	add_btn.pressed.connect(_on_add_pressed)
	add_row.add_child(add_btn)

	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.add_theme_constant_override("separation", 6)
	add_child(status_row)
	_status = Label.new()
	_status.add_theme_color_override("font_color", Color(0.65, 0.68, 0.75))
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_child(_status)
	var gen_btn: Button = Button.new()
	gen_btn.text = "生成"
	gen_btn.pressed.connect(_on_generate_pressed)
	status_row.add_child(gen_btn)
	var reset_btn: Button = Button.new()
	reset_btn.text = "恢复默认"
	reset_btn.pressed.connect(_on_reset_pressed)
	status_row.add_child(reset_btn)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.custom_minimum_size = Vector2(0, 1)
	_list.add_theme_constant_override("separation", 2)
	scroll.add_child(_list)

	_reload_from_disk()


func _reload_from_disk() -> void:
	_names = _CHANNELS_CONFIG.load_names()
	_rebuild_list()
	_set_status("已加载 %d 条轨" % _names.size())


func _rebuild_list() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	if _names.is_empty():
		var empty: Label = Label.new()
		empty.text = "暂无轨（上方添加，或点「恢复默认」）"
		_list.add_child(empty)
		return
	for i: int in range(_names.size()):
		var channel: String = _names[i]
		var stripe: PanelContainer = PanelContainer.new()
		stripe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stripe.add_theme_stylebox_override(&"panel", _row_stripe_stylebox((i % 2) == 1))
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label: Label = Label.new()
		name_label.text = channel
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.tooltip_text = "GDFrame.audio.play_%s" % _AUDIO_API_GEN.method_suffix(channel)
		row.add_child(name_label)
		var impl_btn: Button = Button.new()
		impl_btn.text = "定位实现"
		impl_btn.tooltip_text = "打开播放实现"
		impl_btn.pressed.connect(_open_script.bind(_AUDIO_API_GEN.SERVICE_PATH))
		row.add_child(impl_btn)
		var gen_btn: Button = Button.new()
		gen_btn.text = "定位生成器"
		gen_btn.tooltip_text = "打开生成 play_* 方法的脚本"
		gen_btn.pressed.connect(_open_script.bind(_AUDIO_API_GEN.GENERATOR_PATH))
		row.add_child(gen_btn)
		var del_btn: Button = Button.new()
		del_btn.text = "删除"
		del_btn.pressed.connect(_on_delete_pressed.bind(channel))
		row.add_child(del_btn)
		stripe.add_child(row)
		_list.add_child(stripe)


func _row_stripe_stylebox(use_alt: bool) -> StyleBoxFlat:
	var idx: int = 1 if use_alt else 0
	if _row_stripe_boxes[idx] == null:
		var gui: Control = EditorInterface.get_base_control()
		var c_a: Color = gui.get_theme_color(&"dark_color_1", &"Editor")
		var c_b: Color = gui.get_theme_color(&"dark_color_2", &"Editor")
		var bg: Color = c_b if use_alt else c_a
		if c_a.is_equal_approx(c_b):
			bg = c_a if not use_alt else c_a.darkened(0.1)
		var sb: StyleBoxFlat = StyleBoxFlat.new()
		sb.bg_color = bg
		sb.set_corner_radius_all(2)
		sb.set_content_margin_all(4)
		_row_stripe_boxes[idx] = sb
	return _row_stripe_boxes[idx] as StyleBoxFlat


func _on_add_pressed() -> void:
	var raw: String = _name_edit.text.strip_edges()
	if not _CHANNELS_CONFIG.is_valid_channel_name(raw):
		_set_status("轨名无效（须为标识符：字母/下划线开头）")
		return
	for existing: String in _names:
		if existing == raw:
			_set_status("轨名已存在：%s" % raw)
			return
	_names.append(raw)
	_name_edit.text = ""
	_rebuild_list()
	_set_status("已添加 %s（未生成）" % raw)


func _on_delete_pressed(channel: String) -> void:
	var next := PackedStringArray()
	for name: String in _names:
		if name != channel:
			next.append(name)
	_names = next
	_rebuild_list()
	_set_status("已删除 %s（未生成）" % channel)


func _on_generate_pressed() -> void:
	var built: Dictionary = _AUDIO_API_GEN.build(_names)
	if not bool(built.get("ok", false)):
		_set_status(str(built.get("message", "生成失败")))
		return
	var save_err: Error = _CHANNELS_CONFIG.save_names(_names)
	if save_err != OK:
		_set_status("写入轨配置失败（%s）" % error_string(save_err))
		return
	var gen_err: Error = _AUDIO_API_GEN.write_content(str(built.get("content", "")))
	if gen_err != OK:
		_set_status("生成 API 失败（%s）" % error_string(gen_err))
		return
	_names = _CHANNELS_CONFIG.load_names()
	_rebuild_list()
	var fs: EditorFileSystem = EditorInterface.get_resource_filesystem()
	fs.update_file(_CHANNELS_CONFIG.CHANNELS_CFG_PATH)
	fs.update_file(_AUDIO_API_GEN.AUDIO_CHANNELS_PATH)
	_set_status(str(built.get("message", "")))


func _open_script(path: String) -> void:
	EditorInterface.get_file_system_dock().navigate_to_path(path)
	EditorInterface.edit_script(load(path) as Script)
	_set_status("已打开 %s" % path.get_file())


func _on_reset_pressed() -> void:
	_names = _CHANNELS_CONFIG.DEFAULT_NAMES.duplicate()
	_rebuild_list()
	_set_status("已恢复默认示例（未生成）")


func _set_status(text: String) -> void:
	_status.text = "状态: %s" % text
