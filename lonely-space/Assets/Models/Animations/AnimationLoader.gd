@tool
extends Node

# --- INSTRUCCIONES ---
# 1. Añade este script como un nodo hijo de tu "MixamoPlayer".
# 2. Selecciona este nodo "AnimationLoader" en el árbol de la escena.
# 3. En el Inspector, verás un botón que dice "Cargar Animaciones". Haz clic en él.
# 4. Revisa la consola de "Salida" para ver los mensajes de éxito.
# 5. Una vez que funcione, puedes eliminar este nodo. Los cambios se guardarán en el AnimationPlayer.

@export var _load_animations_button: bool = false:
	set(value):
		if value:
			load_animations_into_player()

func load_animations_into_player():
	var parent = get_parent()
	if not parent:
		print("ERROR: Este script debe ser hijo del nodo del jugador (MixamoPlayer).")
		return

	# --- CONFIGURACIÓN ---
	# Asegúrate de que esta ruta al AnimationPlayer es correcta
	var anim_player_path = "Ch19_nonPBR/AnimationPlayer"
	# Nombre de la nueva librería editable que crearemos
	var new_library_name = "movimiento"
	# Lista de animaciones a cargar
	var animations_to_load = {
		"idle": "res://Assets/Models/Animations/idle.res",
		"run": "res://Assets/Models/Animations/run.res",
		"jump": "res://Assets/Models/Animations/jump_new.res"
	}
	# --- FIN DE LA CONFIGURACIÓN ---


	var anim_player: AnimationPlayer = parent.get_node_or_null(anim_player_path)
	if not anim_player:
		print("ERROR: No se encontró el AnimationPlayer en la ruta: '", anim_player_path, "'. Revisa la ruta en el script.")
		return

	# Crear la librería si no existe
	if not anim_player.has_animation_library(new_library_name):
		anim_player.add_animation_library(new_library_name, AnimationLibrary.new())
		print("Librería '", new_library_name, "' creada.")

	# Cargar cada animación en la nueva librería
	for anim_name in animations_to_load:
		var file_path = animations_to_load[anim_name]
		var anim_resource = load(file_path)

		if anim_resource:
			var final_anim_name = new_library_name + "/" + anim_name
			anim_player.get_animation_library(new_library_name).add_animation(anim_name, anim_resource)
			print("ÉXITO: Animación '", file_path, "' cargada como '", final_anim_name, "'.")
		else:
			print("ERROR: No se pudo cargar el recurso de animación en la ruta: '", file_path, "'. Revisa que el archivo exista.")

	print("--- Proceso completado. ---")
