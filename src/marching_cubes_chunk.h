#ifndef MARCHING_CUBES_CHUNK_H
#define MARCHING_CUBES_CHUNK_H

#include <godot_cpp/classes/collision_shape3d.hpp>
#include <godot_cpp/classes/concave_polygon_shape3d.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/fast_noise_lite.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/static_body3d.hpp>
#include <godot_cpp/variant/vector3i.hpp>

#include <vector>

namespace godot {

class MarchingCubesChunk : public MeshInstance3D {
  GDCLASS(MarchingCubesChunk, MeshInstance3D)

private:
  Vector3i chunk_size;
  Vector3i chunk_coord;
  double isolevel;

  // Ruidos
  Ref<FastNoiseLite> noise_base_terrain;
  Ref<FastNoiseLite> noise_detail;
  Ref<FastNoiseLite> noise_caves;

  // Parámetros de influencia
  double base_terrain_scale;
  double base_terrain_height_influence;
  double detail_scale;
  double detail_influence;
  double cave_scale;
  double cave_density_threshold;

  StaticBody3D *static_body = nullptr;
  CollisionShape3D *collision_shape = nullptr;

  static const int edge_table[256];
  static const int tri_table[256][16];
  static const Vector3i CUBE_VERTICES[8];
  static const int CUBE_EDGES[12][2];

  double calculate_world_density(const Vector3 &world_voxel_coord);
  Vector3 vertex_interpolate(const Vector3 &p1, const Vector3 &p2, double val1,
                             double val2);
  Vector3 calculate_vertex_normal(const Vector3 &world_pos);

protected:
  static void _bind_methods();

public:
  MarchingCubesChunk();
  ~MarchingCubesChunk();

  void _ready() override;

  void generate_mesh();

  void set_chunk_size(const Vector3i &p_size);
  Vector3i get_chunk_size() const;

  void set_chunk_coord(const Vector3i &p_coord);
  Vector3i get_chunk_coord() const;

  void set_isolevel(double p_isolevel);
  double get_isolevel() const;

  void set_base_terrain_scale(double p_scale);
  double get_base_terrain_scale() const;

  void set_detail_scale(double p_scale);
  double get_detail_scale() const;

  void set_cave_scale(double p_scale);
  double get_cave_scale() const;

  void set_base_terrain_height_influence(double p_influence);
  double get_base_terrain_height_influence() const;

  void set_detail_influence(double p_influence);
  double get_detail_influence() const;

  void set_cave_density_threshold(double p_threshold);
  double get_cave_density_threshold() const;

  void set_noise_base_terrain(const Ref<FastNoiseLite> &p_noise);
  Ref<FastNoiseLite> get_noise_base_terrain() const;
  void set_noise_detail(const Ref<FastNoiseLite> &p_noise);
  Ref<FastNoiseLite> get_noise_detail() const;
  void set_noise_caves(const Ref<FastNoiseLite> &p_noise);
  Ref<FastNoiseLite> get_noise_caves() const;
};

} // namespace godot

#endif // MARCHING_CUBES_CHUNK_H
