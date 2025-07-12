extends CharacterBody3D
# lintern  
# Cambia $SpotLight3D por la ruta correcta si lo pusiste en otro lugar.
@onready var linterna = $CameraController/CameraTarget/SpotLight3D
	

const SPEED = 5.0
const JUMP_VELOCITY = 8

var was_on_floor := true

var xform: Transform3D



func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#Play animation:
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	$Ch19_nonPBR/AnimationPlayer.play("movimiento/jump")
	#elif is_on_floor() and input_dir!= Vector2.ZERO:
	#	$Ch19_nonPBR/AnimationPlayer.play("movimiento/run")
	#elif is_on_floor() and input_dir==Vector2.ZERO:
	#	$Ch19_nonPBR/AnimationPlayer.play("movimiento/idle")
	
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
		$"Ch19_nonPBR/AnimationPlayer".play("movimiento/jump_start")


	
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
	
	# --- NUEVA LÓGICA DE ANIMACIÓN ---
	var anim_player = $"Ch19_nonPBR/AnimationPlayer"

	# 1. Lógica de Aterrizaje
	# Si estamos en el suelo AHORA, pero NO lo estábamos ANTES, significa que acabamos de aterrizar.
	if is_on_floor() and not was_on_floor:
		anim_player.play("movimiento/jump_land")

	# 2. Lógica de Suelo (Correr y Reposo)
	# Solo se ejecuta si estamos en el suelo y no estamos en medio de la animación de aterrizaje.
	if is_on_floor() and not anim_player.current_animation == "movimiento/jump_land":
		if input_dir != Vector2.ZERO:
			anim_player.play("movimiento/run")
		else:
			anim_player.play("movimiento/idle")
			
	# 3. Lógica de Aire (Bucle de Caída)
	# Si no estamos en el suelo...
	elif not is_on_floor():
		# ...y no estamos ya en la animación de despegue o en el bucle de caída,
		# reproducimos el bucle de caída. Esto evita cortar la animación de despegue.
		if not ["movimiento/jump_start", "movimiento/jump_loop"].has(anim_player.current_animation):
			anim_player.play("movimiento/jump_loop")

	# Al final de la función, actualizamos el estado para el próximo fotograma.
	was_on_floor = is_on_floor()
	
	# Make camera controller match position of the character	
	$CameraController.position = lerp($CameraController.position, position,0.15);

func align_with_floor(floor_normal) -> void:
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
	
# Esta función recibe un valor booleano (true o false) para encender/apagar.
func activar_linterna(activar: bool):
	linterna.visible = activar
	# Este print es opcional, pero muy útil para saber si la función se está llamando.
	print("Linterna ha sido ", "encendida" if activar else "apagada")
