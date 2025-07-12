extends PanelContainer

# Señal para avisar a la pantalla principal que este slot ha sido seleccionado
signal slot_selected(character_data)

# Referencia al botón que mostrará la imagen del personaje
@onready var texture_button = $TextureButton

var character_data: CharacterManager.CharacterInfo

func _ready():
	# Conectamos la señal "pressed" del botón a una función en este script
	texture_button.pressed.connect(_on_button_pressed)

# Esta función es llamada desde la pantalla de selección para configurar la tarjeta
func set_data(data: CharacterManager.CharacterInfo):
	character_data = data
	texture_button.texture_normal = load(character_data.icon_path)

# Cuando el botón es presionado, emitimos nuestra señal personalizada
func _on_button_pressed():
	emit_signal("slot_selected", character_data)
