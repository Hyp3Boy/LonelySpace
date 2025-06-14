
extends Node3D

# --- Configuración del Manager ---
@export var player_node_path: NodePath # Ruta al nodo del jugador/cámara
var player: Node3D

@export var chunk_scene: PackedScene # La escena VoxelChunk.tscn

@export var chunk_size_units := Vector3(16.0, 16.0, 16.0) # Tamaño de un chunk EN UNIDADES DEL MUNDO.
													   # DEBE COINCIDIR CON LO QUE GENERA VoxelChunk.gd
													   # (si VoxelChunk.gd genera vértices de 0 a 15, entonces es 16)
@export var render_distance_chunks := Vector3i(3, 2, 3) # Cuántos chunks renderizar en cada dirección (X, Y, Z)
													   # (3 significa -3 a +3, total 7 chunks en esa dirección)

@export var update_interval := 0.5 # Segundos entre cada actualización de chunks
var time_since_last_update := 0.0

var active_chunks: Dictionary = {} # Almacena los chunks activos: {Vector3i_coord: VoxelChunk_instance}
var chunks_to_generate: Array[Vector3i] = []
var chunks_to_remove: Array[Node] = [] # Almacenamos nodos para eliminarlos de forma segura

var current_player_chunk_coord := Vector3i(9999, 9999, 9999) # Coord del chunk del jugador, inicializada a algo inválido

func _ready():
	if not chunk_scene:
		printerr("TerrainManager: Chunk Scene not set!")
		set_process(false) # Detener el procesamiento si no hay escena de chunk
		return

	if get_node_or_null(player_node_path):
		player = get_node(player_node_path)
	else:
		printerr("TerrainManager: Player node not found at path: ", player_node_path)
		set_process(false)
		return
		
	# Asegurarse de que chunk_size_units no sea cero para evitar división por cero
	if chunk_size_units.x == 0.0: chunk_size_units.x = 1.0
	if chunk_size_units.y == 0.0: chunk_size_units.y = 1.0
	if chunk_size_units.z == 0.0: chunk_size_units.z = 1.0

	# Forzar una actualización inicial
	_update_chunks_visibility()


func _process(delta: float):
	time_since_last_update += delta
	if time_since_last_update >= update_interval:
		time_since_last_update = 0.0
		_update_chunks_visibility()
	
	_process_chunk_generation_queue()
	_process_chunk_removal_queue()

func _get_chunk_coord_from_world_pos(world_pos: Vector3) -> Vector3i:
	var coord_x = floor(world_pos.x / chunk_size_units.x)
	var coord_y = floor(world_pos.y / chunk_size_units.y)
	var coord_z = floor(world_pos.z / chunk_size_units.z)
	return Vector3i(int(coord_x), int(coord_y), int(coord_z))

func _update_chunks_visibility():
	if not is_instance_valid(player):
		return

	var new_player_chunk_coord = _get_chunk_coord_from_world_pos(player.global_position)

	# Si el jugador no ha cambiado de chunk, no necesitamos recalcular todo (optimización simple)
	# Podrías quitar esto si quieres que siempre se verifique o si tienes chunks que aparecen/desaparecen por otras razones
	if new_player_chunk_coord == current_player_chunk_coord and chunks_to_generate.is_empty():
		return
	
	current_player_chunk_coord = new_player_chunk_coord
	
	var chunks_to_keep: Dictionary = {}

	# Iterar sobre el volumen de renderizado alrededor del jugador
	for x_offset in range(-render_distance_chunks.x, render_distance_chunks.x + 1):
		for y_offset in range(-render_distance_chunks.y, render_distance_chunks.y + 1): # Para terreno 3D
		#for y_offset in range(0, 1): # Si solo quieres un nivel de chunks en Y (ej. para heightmaps)
			for z_offset in range(-render_distance_chunks.z, render_distance_chunks.z + 1):
				var target_chunk_coord = current_player_chunk_coord + Vector3i(x_offset, y_offset, z_offset)
				
				if active_chunks.has(target_chunk_coord):
					# Este chunk ya existe y debe mantenerse
					chunks_to_keep[target_chunk_coord] = active_chunks[target_chunk_coord]
					active_chunks.erase(target_chunk_coord) # Quitar de active_chunks para que los restantes sean los que hay que eliminar
				else:
					# Este chunk necesita ser generado
					if not chunks_to_generate.has(target_chunk_coord): # Evitar duplicados en la cola
						chunks_to_generate.append(target_chunk_coord)

	# Los chunks que quedan en active_chunks ya no están en el radio de visión y deben ser eliminados
	for chunk_node in active_chunks.values():
		if is_instance_valid(chunk_node) and not chunks_to_remove.has(chunk_node):
			chunks_to_remove.append(chunk_node)
	
	active_chunks = chunks_to_keep

# Procesar la cola de generación (un chunk por frame para no sobrecargar)
func _process_chunk_generation_queue():
	if not chunks_to_generate.is_empty():
		var coord_to_generate: Vector3i = chunks_to_generate.pop_front()
		
		# Doble chequeo por si se añadió a la cola de eliminación mientras esperaba
		if active_chunks.has(coord_to_generate):
			return # Ya existe o se está manteniendo, no generar de nuevo

		# Instanciar y configurar el nuevo chunk
		var new_chunk_instance = chunk_scene.instantiate() as MeshInstance3D # Asumimos que la raíz de VoxelChunk.tscn es MeshInstance3D
		if not new_chunk_instance:
			printerr("Failed to instantiate chunk scene!")
			return

		add_child(new_chunk_instance) # Añadir como hijo del TerrainManager
		
		# Posicionar el chunk en el mundo
		new_chunk_instance.position = Vector3(
			float(coord_to_generate.x) * chunk_size_units.x,
			float(coord_to_generate.y) * chunk_size_units.y,
			float(coord_to_generate.z) * chunk_size_units.z
		)
		
		# Pasar la coordenada del chunk al script VoxelChunk.gd para que se genere correctamente
		# Esto asume que VoxelChunk.gd tiene una propiedad exportada llamada "chunk_coord"
		# y un setter que llama a generate_mesh()
		if new_chunk_instance.has_method("set_chunk_coord_and_generate"): # Método preferido para asegurar la generación
			new_chunk_instance.set_chunk_coord_and_generate(coord_to_generate)
		elif new_chunk_instance.has_meta("chunk_coord_property_name"): # Alternativa si expones la prop
			var prop_name = new_chunk_instance.get_meta("chunk_coord_property_name", "chunk_coord")
			new_chunk_instance.set(prop_name, coord_to_generate)
		elif new_chunk_instance.has_property("chunk_coord"): # Intento genérico
			new_chunk_instance.set("chunk_coord", coord_to_generate)
		else:
			printerr("VoxelChunk instance does not have a 'chunk_coord' property or 'set_chunk_coord_and_generate' method.")

		active_chunks[coord_to_generate] = new_chunk_instance

func _process_chunk_removal_queue():
	if not chunks_to_remove.is_empty():
		var chunk_to_remove: Node = chunks_to_remove.pop_front()
		if is_instance_valid(chunk_to_remove):
			# print("Removing chunk: ", chunk_to_remove.name, " at coord: ", (chunk_to_remove as MeshInstance3D).get("chunk_coord") ) # Para depuración
			chunk_to_remove.queue_free()

# --- Modificación sugerida para VoxelChunk.gd ---
# Añade este método a tu VoxelChunk.gd para asegurar que la generación ocurra después de ser añadido al árbol
# y de que se establezca la coordenada.

# En VoxelChunk.gd:
# func set_chunk_coord_and_generate(new_coord: Vector3i):
#    chunk_coord = new_coord # Esto debería llamar al setter que tienes que llama a generate_mesh()
#    # Si tu setter de chunk_coord no llama a generate_mesh() o no lo hace si no está en el árbol,
#    # podrías forzarlo aquí si es necesario:
#    # if is_inside_tree():
#    #    generate_mesh()
#    # O, si generate_mesh() es seguro de llamar antes de _ready:
#    # generate_mesh()
