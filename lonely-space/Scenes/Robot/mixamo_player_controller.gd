extends CharacterBody3D

# --- Variables de Linterna y Mundo ---
@onready var linterna = $CameraController/CameraTarget/SpotLight3D
var world_animation_player: AnimationPlayer = null
var linterna_esta_encendida: bool = false

# --- Variables de Movimiento y Cámara ---
const SPEED = 5.0
const JUMP_VELOCITY = 8.0
const MOUSE_SENSITIVITY = 0.002 # Sensibilidad del ratón

# NUEVO: Límites para la rotación vertical de la cámara (en radianes)
const MIN_PITCH = deg_to_rad(-70.0)
const MAX_PITCH = deg_to_rad(70.0)

# NUEVO: Velocidad a la que el personaje gira para mirar en la dirección de movimiento
const TURN_SPEED = 10.0

# --- Variables de Estado ---
var was_on_floor := true
var xform: Transform3D

# --- Referencias a Nodos ---
# NUEVO: Guardamos una referencia al pivote de la cámara para no buscarlo cada fotograma
@onready var camera_pivot = $CameraController/CameraTarget


func _ready():
	world_animation_player = get_tree().get_root().find_child("WorldTime_AnimationPlayer", true, false)
	if world_animation_player and world_animation_player.is_playing():
		print("El AnimationPlayer encontrado y reproduciendo es: ", world_animation_player.get_path())
	else:
		print("¡ADVERTENCIA! No se encontró ningún AnimationPlayer.")
		
	# Capturar el cursor del mouse para control de cámara
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# NUEVO: Toda la lógica de la cámara se mueve a _unhandled_input para más fluidez
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotación Horizontal (Yaw): Rota el CameraController completo para que el personaje sepa "hacia adelante"
		$CameraController.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Rotación Vertical (Pitch): Rota solo el pivote de la cámara para mirar arriba/abajo
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		# Limitar la rotación vertical para que no de la vuelta completa
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, MIN_PITCH, MAX_PITCH)
		
func _physics_process(delta: float) -> void:
	# MODIFICADO: Usamos las nuevas acciones de input para WASD
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# --- Gravedad ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- Salto ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$"Ch19_nonPBR/AnimationPlayer".play("movimiento/jump_start")

	# --- Dirección de Movimiento ---
	# Calcula la dirección del movimiento en el espacio del mundo, basada en la orientación de la cámara
	var direction = ($CameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# MODIFICADO: Lógica de rotación del personaje
	if direction != Vector3.ZERO:
		# Hacemos que el personaje mire suavemente en la dirección a la que se mueve
		var target_basis = Basis.looking_at(-direction, Vector3.UP)
		$Ch19_nonPBR.basis = $Ch19_nonPBR.basis.slerp(target_basis, delta * TURN_SPEED)
	
	# --- Alineación con el Suelo ---
	if is_on_floor():
		align_with_floor(Vector3.UP)
		$RayCast3D.global_transform = xform
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform, 0.15)
	else:
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.15)
	
	# --- Actualizar Velocidad y Mover ---
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
		
	# --- Lógica de la Linterna (sin cambios) ---
	if world_animation_player and world_animation_player.is_playing():
		var tiempo_actual = world_animation_player.current_animation_position
		var deberia_estar_encendida = (tiempo_actual >= 175.0 and tiempo_actual < 273.5)
		if deberia_estar_encendida and not linterna.visible:
			linterna.visible = true
		elif not deberia_estar_encendida and linterna.visible:
			linterna.visible = false
	
	# --- Lógica de Animación (sin cambios) ---
	var anim_player = $"Ch19_nonPBR/AnimationPlayer"
	if is_on_floor() and not was_on_floor:
		anim_player.play("movimiento/jump_land")
	if is_on_floor() and not anim_player.current_animation == "movimiento/jump_land":
		if input_dir != Vector2.ZERO:
			anim_player.play("movimiento/run")
		else:
			anim_player.play("movimiento/idle")
	elif not is_on_floor():
		if not ["movimiento/jump_start", "movimiento/jump_loop"].has(anim_player.current_animation):
			anim_player.play("movimiento/jump_loop")
	was_on_floor = is_on_floor()
	
	# --- Seguimiento de la Cámara ---
	$CameraController.position = lerp($CameraController.position, position, 0.15)

# --- Función de Alineación con el Suelo (sin cambios) ---
func align_with_floor(floor_normal) -> void:
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
