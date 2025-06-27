extends Node

@export var target_skeleton_path: NodePath
var skeleton: Skeleton3D

# --- Diccionario de Mapeo (Usa los nombres exactos de TUS huesos) ---
var bone_map = {
	"hips": "mixamorig1_Hips",
	"spine": "mixamorig1_Spine",
	"chest": "mixamorig1_Spine2",
	"neck": "mixamorig1_Neck",
	"head": "mixamorig1_Head",
	"left_shoulder": "mixamorig1_LeftShoulder",
	"left_arm": "mixamorig1_LeftArm",
	"left_forearm": "mixamorig1_LeftForeArm",
	"left_hand": "mixamorig1_LeftHand",
	"right_shoulder": "mixamorig1_RightShoulder",
	"right_arm": "mixamorig1_RightArm",
	"right_forearm": "mixamorig1_RightForeArm",
	"right_hand": "mixamorig1_RightHand",
	"left_upleg": "mixamorig1_LeftUpLeg",
	"left_leg": "mixamorig1_LeftLeg",
	"left_foot": "mixamorig1_LeftFoot",
	"right_upleg": "mixamorig1_RightUpLeg",
	"right_leg": "mixamorig1_RightLeg",
	"right_foot": "mixamorig1_RightFoot"

}
var bone_indices = {}
var time_passed_for_test = 0.0

func _ready():
	if target_skeleton_path.is_empty():
		print("ERROR (RetargetingController): target_skeleton_path no está configurado en el Inspector.")
		return

	skeleton = get_node_or_null(target_skeleton_path)
	if not skeleton:
		print("ERROR (RetargetingController): No se pudo encontrar Skeleton3D en la ruta: ", target_skeleton_path)
		return

	print("RetargetingController inicializado para esqueleto: ", skeleton.name)

	for key in bone_map:
		var bone_name = bone_map[key]
		var bone_idx = skeleton.find_bone(bone_name)
		if bone_idx != -1:
			bone_indices[key] = bone_idx
		else:
			print("ADVERTENCIA (RetargetingController): Hueso del mapeo no encontrado: '", bone_name, "' (mapeado a '", key, "')")


func apply_mocap_data(mocap_data: Dictionary):
	if not skeleton or not skeleton.is_inside_tree():
		return

	for bone_key in mocap_data:
		if bone_indices.has(bone_key):
			var bone_idx = bone_indices[bone_key]
			var bone_target_rotation: Quaternion = mocap_data[bone_key]

			skeleton.set_bone_pose_rotation(bone_idx, bone_target_rotation)


# --- TEST ---
func _process(delta):
	if Engine.is_editor_hint():
		return
	
	if not skeleton:
		return

	time_passed_for_test += delta

	var test_mocap_data = {}

	# Mover el antebrazo izquierdo (left_forearm)
	if bone_indices.has("left_forearm"):
		var angle_forearm = sin(time_passed_for_test * 2.0) * (PI / 3.0) # Oscila +/- 60 grados
		test_mocap_data["left_forearm"] = Quaternion(Vector3.FORWARD, angle_forearm) # Rota sobre su eje Z local (hacia adelante)

	# Mover la cabeza (head)
	if bone_indices.has("head"):
		var angle_head = cos(time_passed_for_test * 1.0) * (PI / 6.0) # Oscila +/- 30 grados
		test_mocap_data["head"] = Quaternion(Vector3.UP, angle_head) # Rota sobre su eje Y local (de lado a lado)

	# Mover el brazo derecho (right_arm)
	if bone_indices.has("right_arm"):
		var angle_arm = sin(time_passed_for_test * 1.5 + PI/2.0) * (PI / 4.0) # Oscila +/- 45 grados, desfasado
		test_mocap_data["right_arm"] = Quaternion(Vector3.RIGHT, angle_arm) # Rota sobre su eje X local

	if not test_mocap_data.is_empty():
		apply_mocap_data(test_mocap_data)
