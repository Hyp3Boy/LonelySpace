# SConstruct
import os
import sys

# Carga la configuración de compilación de godot-cpp
env = SConscript("godot-cpp/SConstruct")

# Para referencia:
# - CCFLAGS son flags de compilación compartidos entre C y C++
# - CFLAGS son para flags específicos de C
# - CXXFLAGS son para flags específicos de C++
# - CPPFLAGS son para flags del preprocesador
# - CPPDEFINES son para defines del preprocesador
# - LINKFLAGS son para flags de enlazado

# Agrega nuestra carpeta 'src' a los lugares donde buscar archivos de cabecera (.h)
env.Append(CPPPATH=["src/"])
# Busca todos los archivos .cpp en la carpeta 'src' para compilarlos.
sources = Glob("src/*.cpp")

# CAMBIO: Se ha cambiado el nombre de la librería y la ruta de salida.
# Ahora la librería se llamará "marching_cubes_ext" y se guardará en una carpeta "bin"
# dentro de este mismo directorio de la extensión.

if env["platform"] == "macos":
    library = env.SharedLibrary(
        # CAMBIO: Nombre y ruta de salida para macOS
        "lonely-space/bin/libmarching_cubes_ext.{}.{}.framework/libmarching_cubes_ext.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
elif env["platform"] == "ios":
    if env["ios_simulator"]:
        library = env.StaticLibrary(
            # CAMBIO: Nombre y ruta de salida para iOS Simulator
            "lonely-space/bin/libmarching_cubes_ext.{}.{}.simulator.a".format(env["platform"], env["target"]),
            source=sources,
        )
    else:
        library = env.StaticLibrary(
            # CAMBIO: Nombre y ruta de salida para iOS
            "lonely-space/bin/libmarching_cubes_ext.{}.{}.a".format(env["platform"], env["target"]),
            source=sources,
        )
else:
    # Este bloque maneja Windows, Linux, Android, etc.
    library = env.SharedLibrary(
        # CAMBIO: Nombre y ruta de salida para otras plataformas.
        # Esto construirá el nombre de archivo completo, por ejemplo:
        # bin/libmarching_cubes_ext.windows.debug.x86_64.dll
        "lonely-space/bin/libmarching_cubes_ext{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

# Establece la librería como el objetivo de compilación por defecto.
Default(library)
