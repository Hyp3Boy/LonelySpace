# selection_screen.gd
extends Control

const CharacterSlot = preload("res://Scenes/character_slot.tscn")

@onready var slots_container = $VBoxContainer/HBoxContainer
@onready var start_button = $VBoxContainer/Button

# NUEVO: Una variable para guardar el slot que está actualmente seleccionado
var current_selected_slot = null

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	for char_data in CharacterManager.available_characters:
		var new_slot = CharacterSlot.instantiate()
		slots_container.add_child(new_slot)
		
		new_slot.set_data(char_data)
		# Conectamos a la función que ahora manejará la lógica de selección visual
		new_slot.slot_selected.connect(_on_character_selected)
	
	# Opcional: Seleccionar el primer personaje por defecto
	if slots_container.get_child_count() > 0:
		_on_character_selected(slots_container.get_child(0))

# MODIFICADO: Esta función ahora controla la lógica visual
func _on_character_selected(selected_slot_node):
	# Si ya había un slot seleccionado, le decimos que se deseleccione
	if current_selected_slot:
		current_selected_slot.deselect()
	
	# Le decimos al nuevo slot que se seleccione (muestre su borde)
	selected_slot_node.select()
	
	# Actualizamos nuestra referencia al slot actual
	current_selected_slot = selected_slot_node
	
	# Guardamos los datos del personaje en el manager, como antes
	CharacterManager.selected_character_data = selected_slot_node.character_data
	print("Personaje seleccionado: ", selected_slot_node.character_data.name)

func _on_start_pressed():
	# Solo podemos empezar si se ha seleccionado un personaje
	if current_selected_slot:
		get_tree().change_scene_to_file("res://Scenes/World/main_world.tscn")
	else:
		print("¡No se ha seleccionado ningún personaje!")
