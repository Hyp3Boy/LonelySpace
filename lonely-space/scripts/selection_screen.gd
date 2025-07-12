extends Control

# Asegúrate de que esta ruta a tu escena de slot es correcta
const CharacterSlot = preload("res://Scenes/character_slot.tscn")

# Referencias a los nodos que creamos.
# ¡HAZ DOBLE CLIC Y VERIFICA QUE ESTAS RUTAS SON CORRECTAS!
@onready var slots_container = $VBoxContainer/HBoxContainer
@onready var start_button = $VBoxContainer/Button

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	# Generamos los slots de personaje
	for char_data in CharacterManager.available_characters:
		var new_slot = CharacterSlot.instantiate()
		slots_container.add_child(new_slot)
		
		new_slot.set_data(char_data)
		new_slot.slot_selected.connect(_on_character_selected)

func _on_character_selected(character_data):
	print("Personaje seleccionado: ", character_data.name)
	CharacterManager.selected_character_data = character_data
	# Aquí podrías añadir un feedback visual, como un borde de color

func _on_start_pressed():
	# Cambiamos a la escena principal del juego
	get_tree().change_scene_to_file("res://Scenes/World/main_world.tscn")
