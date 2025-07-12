extends Node
# 1. Definimos una estructura para cada personaje
class CharacterInfo:
	var name: String
	var icon_path: String
	var scene_path: String
	func _init(n, i, s):
		name = n
		icon_path = i
		scene_path = s
		
# 2. Creamos una lista con todos los personajes disponibles
var available_characters = [
	CharacterInfo.new(
		"Guerrero Mixamo",
		"res://Assets/UI/ch1.png", # <-- ¡Necesitarás crear estos iconos!
		"res://Scenes/Robot/mixamo_player.tscn"
	),
	CharacterInfo.new(
		"Guerrero Ch14",
		"res://Assets/UI/ch2.png", # <-- ¡Necesitarás crear estos iconos!
		"res://Scenes/Robot/mixamo_player2.tscn"
	)
	# Puedes añadir más personajes aquí
]

# 3. Guardamos la elección del jugador. Por defecto, el primero.
var selected_character_data: CharacterInfo = available_characters[0]
