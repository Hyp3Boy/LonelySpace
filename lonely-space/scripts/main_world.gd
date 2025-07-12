# Asigna este script al nodo raíz de tu escena "Main World".
extends Node3D

# Asegúrate de que tienes un Marker3D llamado "SpawnPoint" en tu escena.
@onready var spawn_point = $SpawnPoint

# La función _ready() ahora es asíncrona para poder usar 'await'.
# Esto soluciona el error "is_inside_tree()" al esperar un fotograma.
func _ready():
	# Esperamos a que termine el fotograma actual. Esto le da tiempo
	# a todos los nodos de la escena para registrarse correctamente.
	await get_tree().process_frame
	
	# Una vez que es seguro, llamamos a la función para crear al personaje.
	spawn_character()

# Esta función se encarga de todo el proceso de creación del personaje.
func spawn_character():
	# 1. Obtenemos los datos del personaje que el jugador eligió en la pantalla anterior.
	var chosen_character_data = CharacterManager.selected_character_data
	
	# 2. Cargamos el archivo de escena (.tscn) del personaje elegido.
	var character_scene = load(chosen_character_data.scene_path)
	
	if character_scene:
		# 3. Creamos una instancia (una copia) del personaje para ponerla en el mundo.
		var character_instance = character_scene.instantiate()
		
		# 4. Le ponemos el nombre "robot" para que sea fácil de encontrar por otros scripts si fuera necesario.
		character_instance.name = "robot"
		
		# 5. Lo colocamos en la posición y rotación del SpawnPoint.
		character_instance.global_transform = spawn_point.global_transform
		
		# 6. Lo añadimos como un hijo a la escena "Main World".
		add_child(character_instance)
		
		# 7. Buscamos la Camera3D dentro del personaje que acabamos de crear.
		# El 'true, false' busca recursivamente en los hijos, es una forma segura de encontrarla.
		var camera = character_instance.find_child("Camera3D", true, false)
		if camera:
			# 8. La activamos para que el juego renderice desde su punto de vista.
			camera.make_current()
		else:
			printerr("¡ADVERTENCIA! No se encontró una Camera3D en el personaje instanciado.")
			
		print("Personaje '", chosen_character_data.name, "' instanciado en el mundo.")
	else:
		printerr("¡ERROR FATAL! No se pudo cargar la escena del personaje en la ruta: ", chosen_character_data.scene_path)
