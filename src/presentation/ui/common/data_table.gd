class_name DataTable
extends PanelContainer

signal row_clicked(row_data: Dictionary, index: int)

@export var alternate_row_colors: bool = true

var _columns: Array = []
var _rows: Array = []

var _header_container: HBoxContainer
var _rows_scroll: ScrollContainer
var _rows_container: VBoxContainer

func _ready() -> void:
	_build_ui_structure()

func _build_ui_structure() -> void:
	if _header_container != null:
		return
		
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "TableVBox"
	add_child(main_vbox)
	
	_header_container = HBoxContainer.new()
	_header_container.name = "HeaderHBox"
	main_vbox.add_child(_header_container)
	
	var sep = HSeparator.new()
	main_vbox.add_child(sep)
	
	_rows_scroll = ScrollContainer.new()
	_rows_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rows_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(_rows_scroll)
	
	_rows_container = VBoxContainer.new()
	_rows_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows_scroll.add_child(_rows_container)

## Configura as colunas da tabela: [ { "id": "name", "title": "Nome", "width": 180, "align": HORIZONTAL_ALIGNMENT_LEFT } ]
func set_columns(columns: Array) -> void:
	_build_ui_structure()
	_columns = columns.duplicate(true)
	
	for child in _header_container.get_children():
		child.queue_free()
		
	for col in _columns:
		var lbl = Label.new()
		lbl.text = str(col.get("title", ""))
		var w = int(col.get("width", 100))
		lbl.custom_minimum_size = Vector2(w, 24)
		lbl.horizontal_alignment = col.get("align", HORIZONTAL_ALIGNMENT_LEFT)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL if w <= 0 else Control.SIZE_SHRINK_BEGIN
		_header_container.add_child(lbl)

## Define as linhas de dados da tabela
func set_rows(rows_data: Array) -> void:
	_build_ui_structure()
	_rows = rows_data.duplicate(true)
	
	for child in _rows_container.get_children():
		child.queue_free()
		
	for i in range(_rows.size()):
		var row_dict: Dictionary = _rows[i]
		var row_btn = Button.new()
		row_btn.flat = true
		row_btn.custom_minimum_size = Vector2(0, 28)
		row_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var row_hbox = HBoxContainer.new()
		row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_btn.add_child(row_hbox)
		
		for col in _columns:
			var col_id = str(col.get("id", ""))
			var val = row_dict.get(col_id, "")
			var lbl = Label.new()
			lbl.text = str(val)
			var w = int(col.get("width", 100))
			lbl.custom_minimum_size = Vector2(w, 24)
			lbl.horizontal_alignment = col.get("align", HORIZONTAL_ALIGNMENT_LEFT)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL if w <= 0 else Control.SIZE_SHRINK_BEGIN
			row_hbox.add_child(lbl)
			
		var row_idx = i
		row_btn.pressed.connect(func(): row_clicked.emit(row_dict, row_idx))
		_rows_container.add_child(row_btn)

func get_rows_count() -> int:
	return _rows.size()
