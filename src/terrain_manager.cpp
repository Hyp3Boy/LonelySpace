#include "terrain_manager.h"

#include <algorithm> // Para std::sort y std::remove
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot {

void TerrainManager::_bind_methods() {
  ClassDB::bind_method(D_METHOD("set_player_node_path", "p_path"),
                       &TerrainManager::set_player_node_path);
  ClassDB::bind_method(D_METHOD("get_player_node_path"),
                       &TerrainManager::get_player_node_path);
  ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "player_node_path",
                            PROPERTY_HINT_NODE_PATH_VALID_TYPES, "Node3D"),
               "set_player_node_path", "get_player_node_path");

  ClassDB::bind_method(D_METHOD("set_terrain_material", "p_material"),
                       &TerrainManager::set_terrain_material);
  ClassDB::bind_method(D_METHOD("get_terrain_material"),
                       &TerrainManager::get_terrain_material);
  ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "terrain_material",
                            PROPERTY_HINT_RESOURCE_TYPE, "Material"),
               "set_terrain_material", "get_terrain_material");

  ClassDB::bind_method(D_METHOD("set_chunk_size_voxels", "p_size"),
                       &TerrainManager::set_chunk_size_voxels);
  ClassDB::bind_method(D_METHOD("get_chunk_size_voxels"),
                       &TerrainManager::get_chunk_size_voxels);
  ADD_PROPERTY(PropertyInfo(Variant::VECTOR3I, "chunk_size_voxels"),
               "set_chunk_size_voxels", "get_chunk_size_voxels");

  ClassDB::bind_method(D_METHOD("set_chunk_size_units", "p_size"),
                       &TerrainManager::set_chunk_size_units);
  ClassDB::bind_method(D_METHOD("get_chunk_size_units"),
                       &TerrainManager::get_chunk_size_units);
  ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "chunk_size_units"),
               "set_chunk_size_units", "get_chunk_size_units");

  ClassDB::bind_method(D_METHOD("set_render_distance_chunks", "p_dist"),
                       &TerrainManager::set_render_distance_chunks);
  ClassDB::bind_method(D_METHOD("get_render_distance_chunks"),
                       &TerrainManager::get_render_distance_chunks);
  ADD_PROPERTY(PropertyInfo(Variant::VECTOR3I, "render_distance_chunks"),
               "set_render_distance_chunks", "get_render_distance_chunks");

  ClassDB::bind_method(D_METHOD("set_max_concurrent_generations", "p_count"),
                       &TerrainManager::set_max_concurrent_generations);
  ClassDB::bind_method(D_METHOD("get_max_concurrent_generations"),
                       &TerrainManager::get_max_concurrent_generations);
  ADD_PROPERTY(PropertyInfo(Variant::INT, "max_concurrent_generations",
                            PROPERTY_HINT_RANGE, "1,16,1"),
               "set_max_concurrent_generations",
               "get_max_concurrent_generations");

  ClassDB::bind_method(D_METHOD("set_noise_base_terrain", "p_noise"),
                       &TerrainManager::set_noise_base_terrain);
  ClassDB::bind_method(D_METHOD("get_noise_base_terrain"),
                       &TerrainManager::get_noise_base_terrain);
  ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "noise_base_terrain",
                            PROPERTY_HINT_RESOURCE_TYPE, "FastNoiseLite"),
               "set_noise_base_terrain", "get_noise_base_terrain");

  ClassDB::bind_method(D_METHOD("set_noise_detail", "p_noise"),
                       &TerrainManager::set_noise_detail);
  ClassDB::bind_method(D_METHOD("get_noise_detail"),
                       &TerrainManager::get_noise_detail);
  ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "noise_detail",
                            PROPERTY_HINT_RESOURCE_TYPE, "FastNoiseLite"),
               "set_noise_detail", "get_noise_detail");

  ClassDB::bind_method(D_METHOD("set_noise_caves", "p_noise"),
                       &TerrainManager::set_noise_caves);
  ClassDB::bind_method(D_METHOD("get_noise_caves"),
                       &TerrainManager::get_noise_caves);
  ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "noise_caves",
                            PROPERTY_HINT_RESOURCE_TYPE, "FastNoiseLite"),
               "set_noise_caves", "get_noise_caves");

  ClassDB::bind_method(D_METHOD("set_isolevel", "p_level"),
                       &TerrainManager::set_isolevel);
  ClassDB::bind_method(D_METHOD("get_isolevel"), &TerrainManager::get_isolevel);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "isolevel"), "set_isolevel",
               "get_isolevel");

  ClassDB::bind_method(D_METHOD("set_base_terrain_scale", "p_val"),
                       &TerrainManager::set_base_terrain_scale);
  ClassDB::bind_method(D_METHOD("get_base_terrain_scale"),
                       &TerrainManager::get_base_terrain_scale);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "base_terrain_scale"),
               "set_base_terrain_scale", "get_base_terrain_scale");

  ClassDB::bind_method(D_METHOD("set_base_terrain_height_influence", "p_val"),
                       &TerrainManager::set_base_terrain_height_influence);
  ClassDB::bind_method(D_METHOD("get_base_terrain_height_influence"),
                       &TerrainManager::get_base_terrain_height_influence);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "base_terrain_height_influence"),
               "set_base_terrain_height_influence",
               "get_base_terrain_height_influence");

  ClassDB::bind_method(D_METHOD("set_detail_scale", "p_val"),
                       &TerrainManager::set_detail_scale);
  ClassDB::bind_method(D_METHOD("get_detail_scale"),
                       &TerrainManager::get_detail_scale);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "detail_scale"), "set_detail_scale",
               "get_detail_scale");

  ClassDB::bind_method(D_METHOD("set_detail_influence", "p_val"),
                       &TerrainManager::set_detail_influence);
  ClassDB::bind_method(D_METHOD("get_detail_influence"),
                       &TerrainManager::get_detail_influence);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "detail_influence"),
               "set_detail_influence", "get_detail_influence");

  ClassDB::bind_method(D_METHOD("set_cave_scale", "p_val"),
                       &TerrainManager::set_cave_scale);
  ClassDB::bind_method(D_METHOD("get_cave_scale"),
                       &TerrainManager::get_cave_scale);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "cave_scale"), "set_cave_scale",
               "get_cave_scale");

  ClassDB::bind_method(D_METHOD("set_cave_density_threshold", "p_val"),
                       &TerrainManager::set_cave_density_threshold);
  ClassDB::bind_method(D_METHOD("get_cave_density_threshold"),
                       &TerrainManager::get_cave_density_threshold);
  ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "cave_density_threshold"),
               "set_cave_density_threshold", "get_cave_density_threshold");
}

TerrainManager::TerrainManager() {
  player = nullptr;
  chunk_size_voxels = Vector3i(16, 16, 16);
  chunk_size_units = Vector3(16, 16, 16);
  render_distance_chunks = Vector3i(4, 2, 4);
  max_concurrent_generations = 3;
  isolevel = 0.0;
  base_terrain_scale = 0.01;
  base_terrain_height_influence = 50.0;
  detail_scale = 0.1;
  detail_influence = 5.0;
  cave_scale = 0.05;
  cave_density_threshold = 0.5;

  stop_threads = false;
  current_player_chunk_coord = Vector3i(99999, 99999, 99999);
}

TerrainManager::~TerrainManager() { _stop_thread_pool(); }

void TerrainManager::_ready() {
  if (Engine::get_singleton()->is_editor_hint())
    return;

  player = Object::cast_to<Node3D>(get_node_or_null(player_node_path));
  if (!player) {
    UtilityFunctions::push_error(
        "TerrainManager: Player node not found or is not a Node3D.");
    set_process(false);
    return;
  }
  _start_thread_pool();
  _update_chunks_visibility();
}

void TerrainManager::_process(double delta) {
  if (Engine::get_singleton()->is_editor_hint() || !player)
    return;

  _apply_generated_chunks();
  _remove_old_chunks();

  Vector3i new_player_coord =
      _get_chunk_coord_from_world_pos(player->get_global_position());
  if (new_player_coord != current_player_chunk_coord) {
    current_player_chunk_coord = new_player_coord;
    _update_chunks_visibility();
  }
}

void TerrainManager::_notification(int p_what) {
  if (p_what == NOTIFICATION_EXIT_TREE) {
    if (!Engine::get_singleton()->is_editor_hint()) {
      _stop_thread_pool();
    }
  }
}

void TerrainManager::_update_chunks_visibility() {
  std::vector<Vector3i> newly_discovered;
  std::unordered_map<Vector3i, MarchingCubesChunk *, Vector3iHasher>
      chunks_to_keep;

  for (int x = -render_distance_chunks.x; x <= render_distance_chunks.x; ++x) {
    for (int y = -render_distance_chunks.y; y <= render_distance_chunks.y;
         ++y) {
      for (int z = -render_distance_chunks.z; z <= render_distance_chunks.z;
           ++z) {
        Vector3i coord = current_player_chunk_coord + Vector3i(x, y, z);

        if (active_chunks.count(coord)) {
          chunks_to_keep[coord] = active_chunks[coord];
        } else {
          bool already_queued = false;
          {
            std::lock_guard<std::mutex> lock(queue_mutex);
            for (const auto &queued_coord : chunks_in_generation_queue) {
              if (queued_coord == coord) {
                already_queued = true;
                break;
              }
            }
          }
          if (!already_queued) {
            newly_discovered.push_back(coord);
          }
        }
      }
    }
  }

  for (auto const &[coord, chunk] : active_chunks) {
    if (chunks_to_keep.find(coord) == chunks_to_keep.end()) {
      chunks_to_remove_coords.push_back(coord);
    }
  }

  active_chunks = chunks_to_keep;

  if (newly_discovered.empty())
    return;

  std::sort(newly_discovered.begin(), newly_discovered.end(),
            [this](const Vector3i &a, const Vector3i &b) {
              return a.distance_squared_to(current_player_chunk_coord) <
                     b.distance_squared_to(current_player_chunk_coord);
            });

  {
    std::lock_guard<std::mutex> lock(queue_mutex);
    for (const auto &coord : newly_discovered) {
      generation_queue.push_back(coord);
      chunks_in_generation_queue.push_back(coord);
    }
  }
  condition.notify_all();
}

void TerrainManager::_apply_generated_chunks() {
  std::deque<MarchingCubesChunk *> finished_chunks;
  {
    std::lock_guard<std::mutex> lock(queue_mutex);
    if (results_queue.empty())
      return;
    finished_chunks.swap(results_queue);
  }

  for (MarchingCubesChunk *chunk : finished_chunks) {
    Vector3i coord = chunk->get_chunk_coord();

    chunks_in_generation_queue.erase(
        std::remove(chunks_in_generation_queue.begin(),
                    chunks_in_generation_queue.end(), coord),
        chunks_in_generation_queue.end());

    int dist_x = abs(coord.x - current_player_chunk_coord.x);
    int dist_y = abs(coord.y - current_player_chunk_coord.y);
    int dist_z = abs(coord.z - current_player_chunk_coord.z);

    if (dist_x > render_distance_chunks.x ||
        dist_y > render_distance_chunks.y ||
        dist_z > render_distance_chunks.z) {
      memdelete(chunk);
      continue;
    }

    add_child(chunk);
    chunk->set_name(("Chunk_" + String::num_int64(coord.x) + "_" +
                     String::num_int64(coord.y) + "_" +
                     String::num_int64(coord.z)));
    chunk->set_position(Vector3(coord.x, coord.y, coord.z) * chunk_size_units);

    if (chunk->get_mesh().is_valid() &&
        chunk->get_mesh()->get_surface_count() > 0) {
      chunk->set_material_override(terrain_material);
      active_chunks[coord] = chunk;
    } else {
      memdelete(chunk);
    }
  }
}

void TerrainManager::_remove_old_chunks() {
  if (chunks_to_remove_coords.empty())
    return;
  for (const auto &coord : chunks_to_remove_coords) {
    if (active_chunks.count(coord)) {
      MarchingCubesChunk *chunk = active_chunks[coord];
      active_chunks.erase(coord);
      if (chunk && chunk->is_inside_tree()) {
        chunk->queue_free();
      }
    }
  }
  chunks_to_remove_coords.clear();
}

void TerrainManager::_start_thread_pool() {
  stop_threads = false;
  for (int i = 0; i < max_concurrent_generations; ++i) {
    thread_pool.emplace_back(&TerrainManager::_thread_worker_loop, this);
  }
}

void TerrainManager::_stop_thread_pool() {
  {
    std::lock_guard<std::mutex> lock(queue_mutex);
    stop_threads = true;
  }
  condition.notify_all();
  for (std::thread &thread : thread_pool) {
    if (thread.joinable()) {
      thread.join();
    }
  }
  thread_pool.clear();
}

void TerrainManager::_thread_worker_loop() {
  while (true) {
    Vector3i coord_to_generate;
    {
      std::unique_lock<std::mutex> lock(queue_mutex);
      condition.wait(lock, [this] {
        return stop_threads.load() || !generation_queue.empty();
      });

      if (stop_threads.load())
        return;

      coord_to_generate = generation_queue.front();
      generation_queue.pop_front();
    }

    MarchingCubesChunk *chunk = memnew(MarchingCubesChunk);

    chunk->set_chunk_coord(coord_to_generate);
    chunk->set_chunk_size(chunk_size_voxels);
    chunk->set_chunk_size_units(chunk_size_units); // La nueva
    chunk->set_isolevel(isolevel);
    chunk->set_noise_base_terrain(noise_base_terrain);
    chunk->set_noise_detail(noise_detail);
    chunk->set_noise_caves(noise_caves);
    chunk->set_base_terrain_scale(base_terrain_scale);
    chunk->set_base_terrain_height_influence(base_terrain_height_influence);
    chunk->set_detail_scale(detail_scale);
    chunk->set_detail_influence(detail_influence);
    chunk->set_cave_scale(cave_scale);
    chunk->set_cave_density_threshold(cave_density_threshold);

    chunk->generate_mesh();

    {
      std::lock_guard<std::mutex> lock(queue_mutex);
      results_queue.push_back(chunk);
    }
  }
}

// --- Implementación de Setters y Getters ---
void TerrainManager::set_player_node_path(const NodePath &p_path) {
  player_node_path = p_path;
}
NodePath TerrainManager::get_player_node_path() const {
  return player_node_path;
}

void TerrainManager::set_terrain_material(const Ref<Material> &p_material) {
  terrain_material = p_material;
}
Ref<Material> TerrainManager::get_terrain_material() const {
  return terrain_material;
}

void TerrainManager::set_chunk_size_voxels(const Vector3i &p_size) {
  chunk_size_voxels = p_size;
}
Vector3i TerrainManager::get_chunk_size_voxels() const {
  return chunk_size_voxels;
}

void TerrainManager::set_chunk_size_units(const Vector3 &p_size) {
  chunk_size_units = p_size;
}
Vector3 TerrainManager::get_chunk_size_units() const {
  return chunk_size_units;
}

void TerrainManager::set_render_distance_chunks(const Vector3i &p_dist) {
  render_distance_chunks = p_dist;
}
Vector3i TerrainManager::get_render_distance_chunks() const {
  return render_distance_chunks;
}

void TerrainManager::set_max_concurrent_generations(int p_count) {
  max_concurrent_generations = p_count > 0 ? p_count : 1;
}
int TerrainManager::get_max_concurrent_generations() const {
  return max_concurrent_generations;
}

void TerrainManager::set_noise_base_terrain(const Ref<FastNoiseLite> &p_noise) {
  noise_base_terrain = p_noise;
}
Ref<FastNoiseLite> TerrainManager::get_noise_base_terrain() const {
  return noise_base_terrain;
}

void TerrainManager::set_noise_detail(const Ref<FastNoiseLite> &p_noise) {
  noise_detail = p_noise;
}
Ref<FastNoiseLite> TerrainManager::get_noise_detail() const {
  return noise_detail;
}

void TerrainManager::set_noise_caves(const Ref<FastNoiseLite> &p_noise) {
  noise_caves = p_noise;
}
Ref<FastNoiseLite> TerrainManager::get_noise_caves() const {
  return noise_caves;
}

void TerrainManager::set_isolevel(double p_level) { isolevel = p_level; }
double TerrainManager::get_isolevel() const { return isolevel; }

void TerrainManager::set_base_terrain_scale(double p_val) {
  base_terrain_scale = p_val;
}
double TerrainManager::get_base_terrain_scale() const {
  return base_terrain_scale;
}

void TerrainManager::set_base_terrain_height_influence(double p_val) {
  base_terrain_height_influence = p_val;
}
double TerrainManager::get_base_terrain_height_influence() const {
  return base_terrain_height_influence;
}

void TerrainManager::set_detail_scale(double p_val) { detail_scale = p_val; }
double TerrainManager::get_detail_scale() const { return detail_scale; }

void TerrainManager::set_detail_influence(double p_val) {
  detail_influence = p_val;
}
double TerrainManager::get_detail_influence() const { return detail_influence; }

void TerrainManager::set_cave_scale(double p_val) { cave_scale = p_val; }
double TerrainManager::get_cave_scale() const { return cave_scale; }

void TerrainManager::set_cave_density_threshold(double p_val) {
  cave_density_threshold = p_val;
}
double TerrainManager::get_cave_density_threshold() const {
  return cave_density_threshold;
}

Vector3i
TerrainManager::_get_chunk_coord_from_world_pos(const Vector3 &world_pos) {
  if (chunk_size_units.x == 0 || chunk_size_units.y == 0 ||
      chunk_size_units.z == 0)
    return Vector3i();
  return Vector3i(floor(world_pos.x / chunk_size_units.x),
                  floor(world_pos.y / chunk_size_units.y),
                  floor(world_pos.z / chunk_size_units.z));
}

} // namespace godot
