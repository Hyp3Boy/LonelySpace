# pause_menu.gd
extends Control

signal resume_game

func _ready():
	hide()
	$CenterContainer/VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

# Esta función es el centro de control de la pausa
func toggle_pause():
	visible = not visible
	if visible:
		# El juego se está pausando
		# NUEVO: Hacemos que el cursor del ratón sea visible y se pueda mover
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		# El juego se está reanudando
		# NUEVO: Volvemos a capturar el ratón para el control de la cámara
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false

func _on_continue_pressed():
	# Al continuar, reanudamos el juego (lo que también oculta el ratón)
	toggle_pause()

func _on_quit_pressed():
	# ¡IMPORTANTE! Asegurarnos de que el ratón es visible antes de ir al menú principal
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Reanudar el juego ANTES de cambiar de escena
	get_tree().paused = false
	
	# Cambiamos a la escena de selección
	get_tree().change_scene_to_file("res://Scenes/selection_screen.tscn") # Verifica que esta ruta es correcta
