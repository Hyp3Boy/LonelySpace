#ifndef MARCHING_CUBES_CHUNK_H
#define MARCHING_CUBES_CHUNK_H

#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/concave_polygon_shape3d.hpp>
#include <godot_cpp/classes/static_body3d.hpp>
#include <godot_cpp/classes/collision_shape3d.hpp>
#include <godot_cpp/classes/fast_noise_lite.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/vector3i.hpp>

// Incluimos <vector> para usar std::vector en la implementación
#include <vector>

namespace godot {

class MarchingCubesChunk : public MeshInstance3D {
    GDCLASS(MarchingCubesChunk, MeshInstance3D)

private:
    // Propiedades
    Vector3i chunk_size;
    Vector3i chunk_coord;
    double isolevel;
    double noise_scale;
    double noise_height_influence;
    Ref<FastNoiseLite> noise;

    // Nodos hijos
    StaticBody3D* static_body = nullptr;
    CollisionShape3D* collision_shape = nullptr;

    // Tablas de Marching Cubes
    static const int edge_table[256];
    static const int tri_table[256][16];
    static const Vector3i CUBE_VERTICES[8];
    static const int CUBE_EDGES[12][2];

    // Funciones de ayuda
    double calculate_world_density(const Vector3i &world_voxel_coord);
    Vector3 vertex_interpolate(const Vector3& p1, const Vector3& p2, double val1, double val2);

protected:
    static void _bind_methods();

public:
    MarchingCubesChunk();
    ~MarchingCubesChunk();

    void _ready() override;

    // Método de generación explícito
    void generate_mesh();

    // Setters y Getters
    void set_chunk_size(const Vector3i &p_size);
    Vector3i get_chunk_size() const;

    void set_chunk_coord(const Vector3i &p_coord);
    Vector3i get_chunk_coord() const;

    void set_isolevel(double p_isolevel);
    double get_isolevel() const;

    void set_noise_scale(double p_scale);
    double get_noise_scale() const;

    void set_noise_height_influence(double p_influence);
    double get_noise_height_influence() const;

    void set_noise(const Ref<FastNoiseLite> &p_noise);
    Ref<FastNoiseLite> get_noise() const;
};

}

#endif // MARCHING_CUBES_CHUNK_H
