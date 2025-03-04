extends Node
class_name GamepadViewerNode

var gamepad_device := 0

var _window_drag_status := 0
var _window_drag_offset := Vector2()

const WINDOW_DRAG_STATUS_NONE := 0
const WINDOW_DRAG_STATUS_PRESSED := 1
const WINDOW_DRAG_STATUS_PRESSED_AND_MOVED := 2

const CONTEXT_MENU_QUIT := "Quit"
const CONTEXT_MENU_GAMEPAD_PS4 := "PS4"
const CONTEXT_MENU_GAMEPAD_XBOX := "Xbox"
const CONTEXT_MENU_GAMEPAD_DEVICE_1 := "Gamepad #1"
const CONTEXT_MENU_GAMEPAD_DEVICE_2 := "Gamepad #2"
const CONTEXT_MENU_GAMEPAD_DEVICE_3 := "Gamepad #3"
const CONTEXT_MENU_GAMEPAD_DEVICE_4 := "Gamepad #4"
const CONTEXT_MENU_BACKGROUND_COLOR_WHITE := "White"
const CONTEXT_MENU_BACKGROUND_COLOR_MAGENTA := "Magenta"
const CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT := "Transparent"

const CONTEXT_MENU_DEVICES := [CONTEXT_MENU_GAMEPAD_DEVICE_1, CONTEXT_MENU_GAMEPAD_DEVICE_2, CONTEXT_MENU_GAMEPAD_DEVICE_3, CONTEXT_MENU_GAMEPAD_DEVICE_4]
const CONTEXT_MENU_BACKGROUND_COLORS := [CONTEXT_MENU_BACKGROUND_COLOR_WHITE, CONTEXT_MENU_BACKGROUND_COLOR_MAGENTA, CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT]

onready var Background: ColorRect = $Background
onready var ConfigContextMenu: PopupMenu = $ConfigContextMenu

# @impure
func _ready():
	# make the window always on top.
	OS.set_window_always_on_top(true)
	OS.move_window_to_foreground()
	# make the window background transarent.
	get_tree().get_root().set_transparent_background(true)
	# setup the initial context menu options.
	ConfigContextMenu.add_separator("Gamepad")
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_GAMEPAD_PS4)
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_GAMEPAD_XBOX)
	ConfigContextMenu.add_separator("Device")
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_GAMEPAD_DEVICE_1)
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_GAMEPAD_DEVICE_2)
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_GAMEPAD_DEVICE_3)
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_GAMEPAD_DEVICE_4)
	ConfigContextMenu.add_separator("Background")
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_BACKGROUND_COLOR_WHITE)
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_BACKGROUND_COLOR_MAGENTA)
	ConfigContextMenu.add_radio_check_item(CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT)
	ConfigContextMenu.add_separator()
	ConfigContextMenu.add_item(CONTEXT_MENU_QUIT)
	# setup "Gamepad #1" as the default gamepad device.
	_enable_gamepad(CONTEXT_MENU_GAMEPAD_PS4)
	_enable_gamepad_device(CONTEXT_MENU_GAMEPAD_DEVICE_1, 0)
	_enable_gamepad_background_color(CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT)

# @impure
func _input(event: InputEvent):
	if event is InputEventMouse:
		# drag the window around by selecting the content.
		if _window_drag_status == WINDOW_DRAG_STATUS_NONE and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			_window_drag_status = WINDOW_DRAG_STATUS_PRESSED
			_window_drag_offset = OS.window_position - (event.global_position + OS.window_position)
		if _window_drag_status == WINDOW_DRAG_STATUS_PRESSED and event is InputEventMouseMotion:
			_window_drag_status = WINDOW_DRAG_STATUS_PRESSED_AND_MOVED
		if _window_drag_status == WINDOW_DRAG_STATUS_PRESSED_AND_MOVED and event.get_button_mask() != BUTTON_LEFT:
			_window_drag_status = WINDOW_DRAG_STATUS_NONE
		# open the context menu when right-clicking.
		if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and not event.pressed:
			ConfigContextMenu.popup_centered()

# @impure
func _process(_delta: float):
	# drag the window around by selecting the content.
	if _window_drag_status == WINDOW_DRAG_STATUS_PRESSED_AND_MOVED:
		OS.window_position = (get_viewport().get_mouse_position() + OS.window_position) + _window_drag_offset

##
# Gamepad config
##

# @impure
func _enable_gamepad(menu_text: String):
	# check or uncheck in the context menu.
	for item_index in ConfigContextMenu.get_item_count():
		var item_id := ConfigContextMenu.get_item_id(item_index)
		var item_text := ConfigContextMenu.get_item_text(item_index)
		if item_text == CONTEXT_MENU_GAMEPAD_PS4 or item_text == CONTEXT_MENU_GAMEPAD_XBOX:
			ConfigContextMenu.set_item_checked(item_id, item_text == menu_text)
	# display the correct gamepad.
	$PS4_Gamepad.visible = menu_text == CONTEXT_MENU_GAMEPAD_PS4
	$PS4_Gamepad.set_process_input(menu_text == CONTEXT_MENU_GAMEPAD_PS4)
	$Xbox_Gamepad.visible = menu_text == CONTEXT_MENU_GAMEPAD_XBOX
	$Xbox_Gamepad.set_process_input(menu_text == CONTEXT_MENU_GAMEPAD_XBOX)
	
# @impure
func _enable_gamepad_device(menu_text: String, _gamepad_device: int):
	# check or uncheck in the context menu.
	for item_index in ConfigContextMenu.get_item_count():
		var item_id := ConfigContextMenu.get_item_id(item_index)
		var item_text := ConfigContextMenu.get_item_text(item_index)
		if CONTEXT_MENU_DEVICES.has(item_text):
			ConfigContextMenu.set_item_checked(item_id, item_text == menu_text)
	# assign gamepad device.
	gamepad_device = _gamepad_device

# @impure
func _enable_gamepad_background_color(menu_text: String):
	# check or uncheck in the context menu.
	for item_index in ConfigContextMenu.get_item_count():
		var item_id := ConfigContextMenu.get_item_id(item_index)
		var item_text := ConfigContextMenu.get_item_text(item_index)
		if CONTEXT_MENU_BACKGROUND_COLORS.has(item_text):
			ConfigContextMenu.set_item_checked(item_id, item_text == menu_text)
	# assign gamepad background color.
	match menu_text:
		CONTEXT_MENU_BACKGROUND_COLOR_WHITE:
			Background.color = Color.white
			Background.visible = true
		CONTEXT_MENU_BACKGROUND_COLOR_MAGENTA:
			Background.color = Color.magenta
			Background.visible = true
		CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT:
			Background.color = Color.transparent
			Background.visible = false

# @impure
func _on_config_context_menu_id_pressed(id: int):
	match ConfigContextMenu.get_item_text(id):
		CONTEXT_MENU_QUIT: get_tree().quit(0)
		CONTEXT_MENU_GAMEPAD_PS4: _enable_gamepad(CONTEXT_MENU_GAMEPAD_PS4)
		CONTEXT_MENU_GAMEPAD_XBOX: _enable_gamepad(CONTEXT_MENU_GAMEPAD_XBOX)
		CONTEXT_MENU_GAMEPAD_DEVICE_1: _enable_gamepad_device(CONTEXT_MENU_GAMEPAD_DEVICE_1, 0)
		CONTEXT_MENU_GAMEPAD_DEVICE_2: _enable_gamepad_device(CONTEXT_MENU_GAMEPAD_DEVICE_2, 1)
		CONTEXT_MENU_GAMEPAD_DEVICE_3: _enable_gamepad_device(CONTEXT_MENU_GAMEPAD_DEVICE_3, 2)
		CONTEXT_MENU_GAMEPAD_DEVICE_4: _enable_gamepad_device(CONTEXT_MENU_GAMEPAD_DEVICE_4, 3)
		CONTEXT_MENU_BACKGROUND_COLOR_WHITE: _enable_gamepad_background_color(CONTEXT_MENU_BACKGROUND_COLOR_WHITE)
		CONTEXT_MENU_BACKGROUND_COLOR_MAGENTA: _enable_gamepad_background_color(CONTEXT_MENU_BACKGROUND_COLOR_MAGENTA)
		CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT: _enable_gamepad_background_color(CONTEXT_MENU_BACKGROUND_COLOR_TRANSPARENT)

##
# Gamepad helpers
##

# @pure
static func get_gamepad_axis_value(device: int, axis: int, deadzone := 0.15) -> float:
	var axis_value := Input.get_joy_axis(device, axis)
	if abs(axis_value) < deadzone:
		return 0.0
	return axis_value

# @pure
static func is_gamepad_button_pressed(device: int, button_index: int) -> bool:
	return Input.is_joy_button_pressed(device, button_index)
