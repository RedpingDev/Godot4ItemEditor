extends Control

@onready var item_name_input = $"./Panel/VBoxContainer/NameMargin/VBoxContainer/ItemNameInput"
@onready var item_description_input = $"./Panel/VBoxContainer/DescriptionMargin/VBoxContainer/ItemDescriptionInput"
@onready var item_power_input = $"./Panel/VBoxContainer/MarginContainer/VBoxContainer/ItemPowerInput"
@onready var save_button = $"./Panel/VBoxContainer/HBoxContainer/MarginContainer/SaveButton"
@onready var load_button = $"./Panel/VBoxContainer/HBoxContainer/MarginContainer2/LoadButton"
@onready var delete_button = $"./Panel/VBoxContainer/HBoxContainer/MarginContainer3/DeleteButton"
@onready var file_dialog = $FileDialog

const ItemResource = preload("res://item_resource.gd")
var current_action: String = ""  # 현재 수행할 동작을 저장할 변수

@onready var item_image_rect = $"./Panel/VBoxContainer/ImageMargin/VBoxContainer/PanelContainer/ItemImageRect"  # TextureRect 노드
@onready var image_button = $"./Panel/VBoxContainer/ImageMargin/VBoxContainer/SelectImageButton"  # 이미지 선택 버튼
@onready var image_dialog = $ImageFileDialog  # 이미지용 FileDialog


func _on_save_button_pressed():
	current_action = "save"
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_executable_path().get_base_dir()
	file_dialog.current_file = item_name_input.text + ".tres"
	file_dialog.clear_filters()
	file_dialog.add_filter("*.tres; Resource Files")
	file_dialog.popup_centered()

func _on_load_button_pressed():
	current_action = "load"
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_executable_path().get_base_dir()
	file_dialog.popup_centered()

func _on_delete_button_pressed():
	current_action = "delete"
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_executable_path().get_base_dir()
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(path):
	match current_action:
		"save":
			save_item_data(path)
		"load":
			load_item_data(path)
		"delete":
			delete_item_data(path)

func save_item_data(path):
	var resource = ItemResource.new()
	resource.item_name = item_name_input.text
	resource.item_description = item_description_input.text
	resource.item_power = int(item_power_input.text)
	resource.item_image = item_image_rect.texture  # 이미지 저장
	
	var error = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("Failed to save item data: " + str(error))
	else:
		print("Item data saved successfully: " + path)
		clear_input_fields()
# 입력 필드 초기화를 위한 새로운 함수
func clear_input_fields():
	item_name_input.text = ""
	item_description_input.text = ""
	item_power_input.text = "0"
	item_image_rect.texture = null  # 이미지도 초기화

func load_item_data(path):
	var resource = load(path) as ItemResource
	if resource:
		item_name_input.text = resource.item_name
		item_description_input.text = resource.item_description
		item_power_input.text = str(resource.item_power)
		item_image_rect.texture = resource.item_image  # 이미지 로드
		print("Item data loaded successfully: " + path)
	else:
		push_error("Failed to load item data: " + path)

func delete_item_data(path):
	var error = DirAccess.remove_absolute(path)
	if error == OK:
		print("Item data deleted successfully: " + path)
		clear_input_fields()
	else:
		push_error("Failed to delete item data: " + str(error))


func _on_select_image_button_pressed() -> void:
	image_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	image_dialog.access = FileDialog.ACCESS_FILESYSTEM
	image_dialog.current_dir = OS.get_executable_path().get_base_dir()
	image_dialog.clear_filters()
	image_dialog.add_filter("*.png, *.jpg, *.jpeg; Image Files")
	image_dialog.popup_centered()

func _on_image_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	var texture = ImageTexture.new()
	
	if image.load(path) == OK:
		texture = ImageTexture.create_from_image(image)
		item_image_rect.texture = texture
