# LonelySpace

  <!-- Opcional: ¡Añade un banner o un screenshot guay aquí! -->

**LonelySpace** es un prototipo de juego espacial en 3D que explora la generación procedural de terreno en tiempo real utilizando el algoritmo de Marching Cubes. Este proyecto está desarrollado con el motor de juegos **Godot Engine 4.4** y utiliza GDExtension para implementar la lógica de generación de terreno en C++, obteniendo un rendimiento óptimo.

El objetivo principal es crear un sistema de terreno infinito y eficiente que se genere alrededor del jugador mientras este se desplaza por el espacio.

## ✨ Características

-   **Generación de Terreno 3D Procedural:** Crea terreno volumétrico complejo usando el algoritmo de Marching Cubes.
-   **Sistema de Chunks Infinito:** El mundo se genera y se destruye en "chunks" alrededor del jugador, permitiendo un terreno virtualmente infinito.
-   **Alto Rendimiento con GDExtension:** La lógica computacionalmente intensiva de la generación de malla está escrita en C++ para asegurar una experiencia de juego fluida.
-   **Integración con Godot 4.4:** Utiliza las últimas características del motor Godot para el renderizado y la física.

## 🛠️ Tecnologías Utilizadas

-   **Motor de Juego:** [Godot Engine 4.4](https://godotengine.org/)
-   **Lenguajes:**
    -   **C++:** Para la GDExtension de alto rendimiento (Marching Cubes).
    -   **GDScript:** Para la lógica de alto nivel, gestión de escenas y del jugador.
    -   **GLSL:** Shaders personalizados.
    -   **Python:** Para el sistema de compilación SCons.
-   **Sistema de Compilación:** [SCons](https://scons.org/)

## 📋 Requisitos Previos

Antes de empezar, asegúrate de tener instalado el siguiente software en tu sistema:

1.  **Python 3:** SCons depende de Python. Puedes descargarlo desde [python.org](https://www.python.org/downloads/).
    -   Durante la instalación en Windows, asegúrate de marcar la casilla "Add Python to PATH".
2.  **SCons:** Es nuestro sistema de compilación. Una vez que tengas Python instalado, puedes instalar SCons fácilmente abriendo una terminal o línea de comandos y ejecutando:
    ```bash
    pip install scons
    ```
3.  **Un Compilador de C++:** Necesitarás un compilador para construir la GDExtension.
    -   **Windows:** [Visual Studio Community](https://visualstudio.microsoft.com/vs/community/) con la carga de trabajo "Desarrollo de escritorio con C++" instalada.
    -   **macOS:** [Xcode Command Line Tools](https://developer.apple.com/xcode/). Puedes instalarlo ejecutando `xcode-select --install` en la terminal.
    -   **Linux:** El paquete `build-essential` o equivalentes. Por ejemplo, en sistemas basados en Debian/Ubuntu:
        ```bash
        sudo apt-get update && sudo apt-get install build-essential
        ```
4.  **Godot Engine 4.4:** Descarga la versión estándar (no la de .NET) desde la [página oficial de Godot](https://godotengine.org/download/).

## 🚀 Cómo Empezar

Sigue estos pasos para poner el proyecto en funcionamiento en tu máquina local.

### 1. Clonar el Repositorio

Primero, clona este repositorio en tu máquina. Es **muy importante** usar el flag `--recurse-submodules` para descargar también `godot-cpp`, que está incluido como un submódulo de Git.

```bash
git clone --recurse-submodules https://github.com/Hyp3Boy/LonelySpace.git
cd LonelySpace
```

Si olvidaste usar `--recurse-submodules`, puedes inicializarlo después de clonar con estos comandos:
```bash
git submodule update --init --recursive
```

### 2. Compilar la GDExtension del Proyecto

Para que `godot-cpp` esté compilado y construir la GDExtension principal del proyecto. Asegúrate de estar en la **raíz del proyecto** (`LonelySpace`) y ejecuta:

```bash
scons
```

Este comando buscará el archivo `SConstruct`, compilará el código C++ de la carpeta `src/`, y colocará la librería compilada (`.dll`, `.so`, o `.dylib`) en la subcarpeta `lonely-space/bin/`, donde Godot espera encontrarla. Y también al ser recursivo compilará automáticamente los bindings en godot-cpp.

### 3. Abrir en Godot y Ejecutar

¡Ya casi está!

1.  Abre el ejecutable de **Godot Engine 4.4**.
2.  En el gestor de proyectos, haz clic en **"Importar"**.
3.  Navega hasta la carpeta del proyecto clonado y selecciona el archivo `lonely-space/project.godot`.
4.  Una vez que el proyecto se abra en el editor de Godot, simplemente presiona el **botón de Play** (o `F5`) para ejecutar la escena principal.

¡Y eso es todo! Deberías ver el terreno generándose a tu alrededor.

## 🤝 Contribuir

Las contribuciones son bienvenidas. Si tienes ideas para mejorar el sistema de generación, optimizar el código o añadir nuevas características, no dudes en abrir un *Issue* para discutirlo o enviar un *Pull Request*.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---
**¡Disfruta explorando el espacio procedural!** 🚀
