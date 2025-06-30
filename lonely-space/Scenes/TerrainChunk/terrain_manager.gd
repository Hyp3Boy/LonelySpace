extends Node3D

# --- Configuración del Manager ---
@export var player_node_path: NodePath
var player: Node3D

@export var terrain_material: Material

@export_group("Generation Settings")
@export var chunk_size_voxels := Vector3i(16, 16, 16)

@export_group("Noise settings")
@export var noise_base_terrain: FastNoiseLite # Para la forma general del terreno
@export var noise_detail: FastNoiseLite       # Para la rugosidad y detalles finos
@export var noise_caves: FastNoiseLite        # Para generar las cuevas
@export var isolevel := 0.0

@export_group("Noise influence")
@export var base_terrain_scale := 1
@export var base_terrain_height_influence := 50.0

@export var detail_scale := 0.1
@export var detail_influence := 5.0

@export var cave_scale := 0.05
@export var cave_density_threshold := 0.5 # Qué tan "sólido" debe ser el ruido de cueva para crear un agujero


@export_group("Render Settings")
@export var chunk_size_units := Vector3(16.0, 16.0, 16.0)
@export var render_distance_chunks := Vector3i(4, 2, 4)
@export var update_interval := 0.25

var active_chunks: Dictionary = {}
var chunks_to_generate: Array[Vector3i] = []
#var newly_discovered_chunks: Array[Vector3i] = []
var chunks_to_remove: Array[Node] = []
var time_since_last_update := 0.0
var current_player_chunk_coord := Vector3i(9999, 9999, 9999)

func _ready():
	if not get_node_or_null(player_node_path):
		printerr("TerrainManager: Player node not found at path: ", player_node_path)
		set_process(false)
		return
	player = get_node(player_node_path)
	
	if not noise_base_terrain or not noise_detail or not noise_caves:
		printerr("TerrainManager: One of noise resource not set!")
		set_process(false)
		return
	
	if not terrain_material:
		printerr("TerrainManager: Terrain Material not set! The terrain will be invisible.")
	
	_update_chunks_visibility()

func _process(delta: float):
	time_since_last_update += delta
	if time_since_last_update >= update_interval:
		time_since_last_update = 0.0
		_update_chunks_visibility()
	
	if not chunks_to_generate.is_empty():
		_process_one_chunk_generation()
	elif not chunks_to_remove.is_empty():
		_process_one_chunk_removal()

func _get_chunk_coord_from_world_pos(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		floor(world_pos.x / chunk_size_units.x),
		floor(world_pos.y / chunk_size_units.y),
		floor(world_pos.z / chunk_size_units.z)
	)

func _update_chunks_visibility():
	if not is_instance_valid(player): return
	var new_player_chunk_coord = _get_chunk_coord_from_world_pos(player.global_position)
	if new_player_chunk_coord == current_player_chunk_coord: return
	
	current_player_chunk_coord = new_player_chunk_coord
	var chunks_to_keep: Dictionary = {}
	
	var newly_discovered_chunks: Array[Vector3i] = []

	for x in range(-render_distance_chunks.x, render_distance_chunks.x + 1):
		for y in range(-render_distance_chunks.y, render_distance_chunks.y + 1):
			for z in range(-render_distance_chunks.z, render_distance_chunks.z + 1):
				var target_coord = current_player_chunk_coord + Vector3i(x, y, z)
				
				if active_chunks.has(target_coord):
					chunks_to_keep[target_coord] = active_chunks[target_coord]
					active_chunks.erase(target_coord)
				elif not chunks_to_generate.has(target_coord):
					newly_discovered_chunks.append(target_coord)
	
	for chunk_node in active_chunks.values():
		if is_instance_valid(chunk_node) and not chunks_to_remove.has(chunk_node):
			chunks_to_remove.append(chunk_node)
	
	active_chunks = chunks_to_keep
	# === LA MAGIA OCURRE AQUÍ ===
	if not newly_discovered_chunks.is_empty():
		# 1. Ordena la lista de los chunks recién descubiertos por distancia.
		newly_discovered_chunks.sort_custom(_sort_chunks_by_distance)
		
		# 2. Añade los chunks ya ordenados a la cola de generación principal.
		#    Esto asegura que los más cercanos se procesen primero.
		chunks_to_generate.append_array(newly_discovered_chunks)

func _sort_chunks_by_distance(a: Vector3i, b: Vector3i) -> bool:
	var dist_a_sq = current_player_chunk_coord.distance_squared_to(a)
	var dist_b_sq = current_player_chunk_coord.distance_squared_to(b)
	return dist_a_sq < dist_b_sq
	
func _process_one_chunk_generation():
	if chunks_to_generate.is_empty(): return
	
	var coord_to_generate: Vector3i = chunks_to_generate.pop_front()
	
	if active_chunks.has(coord_to_generate): return

	var new_chunk_instance = MarchingCubesChunk.new()
	add_child(new_chunk_instance)
	new_chunk_instance.name = "Chunk_%s_%s_%s" % [coord_to_generate.x, coord_to_generate.y, coord_to_generate.z]
	
	new_chunk_instance.position = Vector3(
		float(coord_to_generate.x) * chunk_size_units.x,
		float(coord_to_generate.y) * chunk_size_units.y,
		float(coord_to_generate.z) * chunk_size_units.z
	)
	
	new_chunk_instance.chunk_coord = coord_to_generate
	new_chunk_instance.chunk_size = chunk_size_voxels
	new_chunk_instance.isolevel = isolevel
	
	new_chunk_instance.noise_base_terrain = noise_base_terrain
	new_chunk_instance.noise_detail = noise_detail
	new_chunk_instance.noise_caves = noise_caves
	
	new_chunk_instance.base_terrain_scale = base_terrain_scale
	new_chunk_instance.base_terrain_height_influence = base_terrain_height_influence
	new_chunk_instance.detail_scale = detail_scale
	new_chunk_instance.detail_influence = detail_influence
	new_chunk_instance.cave_scale = cave_scale
	new_chunk_instance.cave_density_threshold = cave_density_threshold
	
	# La generación de C++ funciona, porque la colisión existe
	new_chunk_instance.generate_mesh()	

	# === CORRECCIÓN AQUÍ ===
	# Asignamos el material a la instancia del nodo, no a la superficie de la malla.
	# Esto asegura que el chunk se renderice con nuestro material.
	var chunk_mesh = new_chunk_instance.get_mesh()
	if chunk_mesh and chunk_mesh.get_surface_count() > 0:
		new_chunk_instance.material_override = terrain_material
		active_chunks[coord_to_generate] = new_chunk_instance
	else:
		new_chunk_instance.queue_free()
	
	# === AÑADE ESTOS PRINTS PARA DEPURAR ===
	if chunk_mesh:
		print("Chunk ", coord_to_generate, " tiene una malla.")
		if chunk_mesh.get_surface_count() > 0:
			var vertex_array = chunk_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
			print(" -> Superficie 0 tiene ", vertex_array.size(), " vértices.")
			new_chunk_instance.material_override = terrain_material
		else:
			print(" -> ADVERTENCIA: La malla no tiene superficies.")
	else:
		print(" -> ERROR: El chunk no tiene recurso de malla asignado.")
	
	active_chunks[coord_to_generate] = new_chunk_instance

func _process_one_chunk_removal():
	if chunks_to_remove.is_empty(): return
	
	var chunk_to_remove: Node = chunks_to_remove.pop_front()
	if is_instance_valid(chunk_to_remove):
		chunk_to_remove.queue_free()
