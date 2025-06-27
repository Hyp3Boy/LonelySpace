extends Skeleton3D

@onready var skeleton: Skeleton3D = self
#@export var target_skeleton_path: NodePath
#var skeleton: Skeleton3D


func _ready():
	print("--- Script en '", self.name, "' (Path: ", self.get_path(), ") iniciando _ready ---")
	if skeleton:
		print("Número de huesos: ", skeleton.get_bone_count())
		for i in range(skeleton.get_bone_count()):
			var bone_name = skeleton.get_bone_name(i)
			print("Hueso ID: ", i, " - Nombre: ", bone_name)
	else:
		# Haz este mensaje de error bien distintivo
		print("!!!! ERROR DESDE EL SCRIPT EN '", self.name, "' (Path: ", self.get_path(), ") !!!!: No se encontró el Skeleton3D en self.")
