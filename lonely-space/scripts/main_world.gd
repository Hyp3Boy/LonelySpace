# Asigna este script al nodo raíz de tu escena "Main World".
extends Node3D

# Referencias a los nodos clave de la escena
@onready var spawn_point = $SpawnPoint
@onready var terrain_manager = $TerrainManager
@onready var pause_menu = $PauseMenu


func _ready():
	await get_tree().process_frame
	spawn_character()

func spawn_character():
	var chosen_character_data = CharacterManager.selected_character_data
	var character_scene = load(chosen_character_data.scene_path)
	
	if character_scene:
		var character_instance = character_scene.instantiate()
		character_instance.name = "robot"
		character_instance.global_transform = spawn_point.global_transform
		add_child(character_instance)
		
		# ¡CAMBIO CLAVE! Llamamos a la función de forma diferida.
		terrain_manager.call_deferred("assign_player_by_path", character_instance.get_path())
		
		var camera = character_instance.find_child("Camera3D", true, false)
		if camera:
			camera.make_current()
		else:
			printerr("¡ADVERTENCIA! No se encontró una Camera3D en el personaje instanciado.")
			
		print("Personaje '", chosen_character_data.name, "' instanciado. Asignación a TerrainManager programada.")
	else:
		printerr("¡ERROR FATAL! No se pudo cargar la escena del personaje en la ruta: ", chosen_character_data.scene_path)
		
func _unhandled_input(event):
	# Comprobamos si se ha pulsado la acción "pause"
	if event.is_action_pressed("pause"):
		# Le decimos al menú que se muestre/oculte y maneje la pausa
		pause_menu.toggle_pause()
		# Marcamos el evento como manejado para que no siga propagándose
		get_tree().get_root().set_input_as_handled()
