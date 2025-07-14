# characterSlot.gd
extends PanelContainer

signal slot_selected(slot_node)

@onready var texture_button = $TextureButton

var character_data = null

var style_normal = StyleBoxFlat.new()
var style_selected = StyleBoxFlat.new()

func _ready():
	style_normal.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	
	style_selected.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	style_selected.border_width_left = 4
	style_selected.border_width_right = 4
	style_selected.border_width_top = 4
	style_selected.border_width_bottom = 4
	style_selected.border_color = Color.AZURE

	deselect()
	
	texture_button.pressed.connect(_on_button_pressed)

func set_data(data):
	character_data = data
	
	if character_data:
		texture_button.texture_normal = load(character_data.icon_path)

# Cuando el botón es presionado, emitimos nuestra señal personalizada
func _on_button_pressed():
	emit_signal("slot_selected", self)

# Se llama para mostrar el borde
func select():
	add_theme_stylebox_override("panel", style_selected)

# Se llama para quitar el borde
func deselect():
	add_theme_stylebox_override("panel", style_normal)
