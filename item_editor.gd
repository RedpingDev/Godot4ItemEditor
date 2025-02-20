extends Control

@onready var item_name_input = $"./HSplitContainer/Panel/VBoxContainer/NameMargin/VBoxContainer/ItemNameInput"
@onready var item_description_input = $"./HSplitContainer/Panel/VBoxContainer/DescriptionMargin/VBoxContainer/ItemDescriptionInput"
@onready var item_power_input = $"./HSplitContainer/Panel/VBoxContainer/MarginContainer/VBoxContainer/ItemPowerInput"
@onready var save_button = $"./HSplitContainer/Panel/VBoxContainer/HBoxContainer/MarginContainer/SaveButton"
@onready var load_button = $"./HSplitContainer/Panel/VBoxContainer/HBoxContainer/MarginContainer2/LoadButton"
@onready var delete_button = $"./HSplitContainer/Panel/VBoxContainer/HBoxContainer/MarginContainer3/DeleteButton"
@onready var file_dialog = $FileDialog
@onready var item_image_rect = $"./HSplitContainer/Panel/VBoxContainer/ImageMargin/VBoxContainer/PanelContainer/ItemImageRect"
@onready var image_button = $"./HSplitContainer/Panel/VBoxContainer/ImageMargin/VBoxContainer/SelectImageButton"
@onready var image_dialog = $ImageFileDialog
@onready var preview_grid = $"./HSplitContainer/PreviewPanel/ScrollContainer/PreviewGrid"

const ItemResource = preload("res://item_resource.gd")
var current_action: String = ""
var current_dir: String = ""
var preview_items: Dictionary = {}

func _ready():
	current_dir = OS.get_executable_path().get_base_dir()
	preview_grid.columns = 3  # 한 줄에 표시할 아이템 수
	refresh_preview_list()

# 프리뷰 리스트 전체 갱신
func refresh_preview_list():
	# 1. 기존 프리뷰 아이템들 제거
	clear_preview_list()
	
	# 2. 디렉토리 스캔
	var dir = DirAccess.open(current_dir)
	if !dir:
		push_error("Failed to access directory: " + current_dir)
		return
		
	# 3. 파일 목록 수집
	var item_files = []
	dir.list_dir_begin()
	var current_file = dir.get_next()
	
	while current_file != "":
		if current_file.ends_with(".tres"):
			item_files.append(current_file)
		current_file = dir.get_next()
	
	# 4. 파일 이름순으로 정렬
	item_files.sort()
	
	# 5. 각 파일에 대해 프리뷰 아이템 생성
	for file_name in item_files:
		var full_path = current_dir.path_join(file_name)
		var item_resource = load(full_path) as ItemResource
		if item_resource:
			add_preview_item(file_name, item_resource)
		else:
			push_warning("Failed to load resource: " + full_path)

# 프리뷰 아이템 추가
func add_preview_item(file_name: String, item_resource: ItemResource):
	# 프리뷰 컨테이너 생성
	var preview_button = Button.new()
	var preview_container = VBoxContainer.new()
	preview_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_container.custom_minimum_size = Vector2(120, 140)
	
	# 이미지 설정
	var preview_image = TextureRect.new()
	preview_image.custom_minimum_size = Vector2(100, 100)
	preview_image.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	preview_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_image.texture = item_resource.item_image if item_resource.item_image else null
	
	# 이름 라벨 설정
	var preview_label = Label.new()
	preview_label.text = item_resource.item_name
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_label.custom_minimum_size = Vector2(100, 30)
	
	# 파워 라벨 설정
	var power_label = Label.new()
	power_label.text = "Power: " + str(item_resource.item_power)
	power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 컨테이너에 요소들 추가
	preview_container.add_child(preview_image)
	preview_container.add_child(preview_label)
	preview_container.add_child(power_label)
	
	# 버튼 설정
	preview_button.add_child(preview_container)
	preview_button.custom_minimum_size = Vector2(120, 140)
	preview_button.pressed.connect(_on_preview_item_selected.bind(file_name))
	
	# 프리뷰 그리드에 추가
	preview_grid.add_child(preview_button)
	preview_items[file_name] = preview_button

# 프리뷰 리스트 클리어
func clear_preview_list():
	for child in preview_grid.get_children():
		preview_grid.remove_child(child)
		child.queue_free()
	preview_items.clear()

# 프리뷰 아이템 선택 처리
func _on_preview_item_selected(file_name: String):
	var path = current_dir.path_join(file_name)
	load_item_data(path)
	
	# 선택된 아이템 하이라이트
	for item in preview_items.values():
		item.modulate = Color.WHITE
	preview_items[file_name].modulate = Color(0.8, 0.9, 1.0, 1.0)

func _on_save_button_pressed():
	current_action = "save"
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = current_dir
	file_dialog.current_file = item_name_input.text + ".tres"
	file_dialog.clear_filters()
	file_dialog.add_filter("*.tres; Resource Files")
	file_dialog.popup_centered()

func save_item_data(path):
	var resource = ItemResource.new()
	resource.item_name = item_name_input.text
	resource.item_description = item_description_input.text
	resource.item_power = int(item_power_input.text)
	resource.item_image = item_image_rect.texture
	
	var error = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("Failed to save item data: " + str(error))
	else:
		print("Item data saved successfully: " + path)
		clear_input_fields()
		refresh_preview_list()  # 프리뷰 리스트 갱신

func _on_load_button_pressed():
	current_action = "load"
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = current_dir
	file_dialog.popup_centered()

func load_item_data(path):
	var resource = load(path) as ItemResource
	if resource:
		item_name_input.text = resource.item_name
		item_description_input.text = resource.item_description
		item_power_input.text = str(resource.item_power)
		item_image_rect.texture = resource.item_image
		print("Item data loaded successfully: " + path)
	else:
		push_error("Failed to load item data: " + path)

func _on_delete_button_pressed():
	current_action = "delete"
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = current_dir
	file_dialog.popup_centered()

func delete_item_data(path):
	var error = DirAccess.remove_absolute(path)
	if error == OK:
		print("Item data deleted successfully: " + path)
		clear_input_fields()
		refresh_preview_list()  # 프리뷰 리스트 갱신
	else:
		push_error("Failed to delete item data: " + str(error))

func clear_input_fields():
	item_name_input.text = ""
	item_description_input.text = ""
	item_power_input.text = "0"
	item_image_rect.texture = null

func _on_select_image_button_pressed() -> void:
	image_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	image_dialog.access = FileDialog.ACCESS_FILESYSTEM
	image_dialog.current_dir = current_dir
	image_dialog.clear_filters()
	image_dialog.add_filter("*.png, *.jpg, *.jpeg; Image Files")
	image_dialog.popup_centered()

func _on_image_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	var texture = ImageTexture.new()
	
	if image.load(path) == OK:
		texture = ImageTexture.create_from_image(image)
		item_image_rect.texture = texture

func _on_file_dialog_file_selected(path):
	match current_action:
		"save":
			save_item_data(path)
		"load":
			load_item_data(path)
		"delete":
			delete_item_data(path)
