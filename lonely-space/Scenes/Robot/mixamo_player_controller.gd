extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6

var xform: Transform3D

# Esta función se ejecuta una sola vez cuando el nodo entra en la escena.
func _ready() -> void:
	# "Congelamos" el nodo. No procesará física, ni input, ni _physics_process.
	process_mode = PROCESS_MODE_DISABLED
	print("Robot: 'Congelado' al inicio. Esperando señal del terreno.")

# Esta es la función que conectaremos a la señal del TerrainManager.
func on_terrain_ready() -> void:
	print("Robot: ¡Señal recibida! 'Descongelando' y activando la física.")
	# Reactivamos el nodo. Ahora la gravedad y el control funcionarán.
	process_mode = PROCESS_MODE_INHERIT


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#Play animation:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$Ch19_nonPBR/AnimationPlayer.play("movimiento/jump")
	elif is_on_floor() and input_dir!= Vector2.ZERO:
		$Ch19_nonPBR/AnimationPlayer.play("movimiento/run")
	elif is_on_floor() and input_dir==Vector2.ZERO:
		$Ch19_nonPBR/AnimationPlayer.play("movimiento/idle")
	
	# Rotate camera left and right
	
	if Input.is_action_just_pressed("cam_left"):
		$CameraController.rotate_y(deg_to_rad(-30))
	if Input.is_action_just_pressed("cam_right"):
		$CameraController.rotate_y(deg_to_rad(30))
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	
	#new vector3 direction taking into account the user arrow input and the camera rotation
	var direction = ($CameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Rotate the character mesh so is orientend in the direction we move
	
	if input_dir != Vector2.ZERO:
		$Ch19_nonPBR.rotation_degrees.y = $CameraController.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90
		
	#rotate the character to align floor normal vector 
	if is_on_floor():
		align_with_floor(Vector3.UP); # EXPLAIN
		$RayCast3D.global_transform = xform; #  EXPLAIN
		align_with_floor($RayCast3D.get_collision_normal());
		global_transform = global_transform.interpolate_with(xform,0.15)
	elif not is_on_floor():
		align_with_floor(Vector3.UP);
		global_transform = global_transform.interpolate_with(xform,0.15)
	
	#UPDATE VELOCITY AND MOVE
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
	
	# Make camera controller match position of the character	
	#$CameraController.position = lerp($CameraController.position, position,0.15);

func align_with_floor(floor_normal) -> void:
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
	


func _on_terrain_manager_initial_terrain_generated() -> void:
	pass # Replace with function body.
