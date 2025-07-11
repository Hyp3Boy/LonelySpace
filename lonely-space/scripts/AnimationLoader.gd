@tool
extends Node

# Botón para activar la carga en el Inspector
@export var _load_animations_button: bool = false:
	set(value):
		if value:
			load_animations_into_player()

func load_animations_into_player():
	var parent = get_parent()
	if not parent:
		printerr("ERROR: AnimationLoader debe ser hijo del nodo del jugador.")
		return

	# --- CONFIGURACIÓN ---
	var anim_player_path = "Ch19_nonPBR/AnimationPlayer"
	var new_library_name = "movimiento"
	var animations_to_load = {
		"idle": "res://Assets/Models/Animations/idle.res",
		"run": "res://Assets/Models/Animations/run.res",
		# Eliminamos la antigua animación de "jump"
		"jump_start": "res://Assets/Models/Animations/jumping_up.res",
		"jump_loop": "res://Assets/Models/Animations/falling_idle.res",
		"jump_land": "res://Assets/Models/Animations/jumping_down.res"
	}
	# --- FIN DE LA CONFIGURACIÓN ---

	var anim_player: AnimationPlayer = parent.get_node_or_null(anim_player_path)
	if not anim_player:
		printerr("ERROR: No se encontró AnimationPlayer en la ruta: '", anim_player_path, "'.")
		return

	if not anim_player.has_animation_library(new_library_name):
		anim_player.add_animation_library(new_library_name, AnimationLibrary.new())
		print("Librería '", new_library_name, "' creada.")

	for anim_name in animations_to_load:
		var file_path = animations_to_load[anim_name]
		var anim_resource = load(file_path)

		if anim_resource:
			var final_anim_name = new_library_name + "/" + anim_name
			anim_player.get_animation_library(new_library_name).add_animation(anim_name, anim_resource)
			print("ÉXITO: Animación '", file_path, "' cargada como '", final_anim_name, "'.")
		else:
			printerr("ERROR: No se pudo cargar la animación en la ruta: '", file_path, "'.")

	print("--- Proceso de carga completado. ---")
