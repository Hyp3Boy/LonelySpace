// terrain_manager.h
#ifndef TERRAIN_MANAGER_H
#define TERRAIN_MANAGER_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/fast_noise_lite.hpp>
#include <godot_cpp/classes/material.hpp>

#include "marching_cubes_chunk.h"

#include <vector>
#include <deque>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <unordered_map>

namespace godot {

struct Vector3iHasher {
    std::size_t operator()(const Vector3i& v) const {
        std::size_t h1 = std::hash<int32_t>{}(v.x);
        std::size_t h2 = std::hash<int32_t>{}(v.y);
        std::size_t h3 = std::hash<int32_t>{}(v.z);
        return h1 ^ (h2 << 1) ^ (h3 << 2);
    }
};

class TerrainManager : public Node3D {
    GDCLASS(TerrainManager, Node3D)

private:
    NodePath player_node_path;
    Node3D* player = nullptr;
    Ref<Material> terrain_material;
    Vector3i chunk_size_voxels;
    Vector3 chunk_size_units;
    Vector3i render_distance_chunks;
    int max_concurrent_generations;

    Ref<FastNoiseLite> noise_base_terrain;
    Ref<FastNoiseLite> noise_detail;
    Ref<FastNoiseLite> noise_caves;
    double isolevel;
    double base_terrain_scale;
    double base_terrain_height_influence;
    double detail_scale;
    double detail_influence;
    double cave_scale;
    double cave_density_threshold;

    Vector3i current_player_chunk_coord;
    std::unordered_map<Vector3i, MarchingCubesChunk*, Vector3iHasher> active_chunks;
    std::deque<Vector3i> chunks_to_remove_coords;
    std::vector<Vector3i> chunks_in_generation_queue;

    std::vector<std::thread> thread_pool;
    std::deque<Vector3i> generation_queue;
    std::deque<MarchingCubesChunk*> results_queue;
    std::mutex queue_mutex;
    std::condition_variable condition;
    std::atomic<bool> stop_threads;

    void _start_thread_pool();
    void _stop_thread_pool();
    void _thread_worker_loop();
    void _update_chunks_visibility();
    void _apply_generated_chunks();
    void _remove_old_chunks();
    Vector3i _get_chunk_coord_from_world_pos(const Vector3& world_pos);

protected:
    static void _bind_methods();

public:
    TerrainManager();
    ~TerrainManager();

    void _ready() override;
    void _process(double delta) override;
    void _notification(int p_what);

    void set_player_node_path(const NodePath& p_path);
    NodePath get_player_node_path() const;

    void set_terrain_material(const Ref<Material>& p_material);
    Ref<Material> get_terrain_material() const;

    void set_chunk_size_voxels(const Vector3i& p_size);
    Vector3i get_chunk_size_voxels() const;

    void set_chunk_size_units(const Vector3& p_size);
    Vector3 get_chunk_size_units() const;

    void set_render_distance_chunks(const Vector3i& p_dist);
    Vector3i get_render_distance_chunks() const;

    void set_max_concurrent_generations(int p_count);
    int get_max_concurrent_generations() const;

    void set_noise_base_terrain(const Ref<FastNoiseLite>& p_noise);
    Ref<FastNoiseLite> get_noise_base_terrain() const;

    void set_noise_detail(const Ref<FastNoiseLite>& p_noise);
    Ref<FastNoiseLite> get_noise_detail() const;

    void set_noise_caves(const Ref<FastNoiseLite>& p_noise);
    Ref<FastNoiseLite> get_noise_caves() const;

    void set_isolevel(double p_level);
    double get_isolevel() const;

    void set_base_terrain_scale(double p_val);
    double get_base_terrain_scale() const;

    void set_base_terrain_height_influence(double p_val);
    double get_base_terrain_height_influence() const;

    void set_detail_scale(double p_val);
    double get_detail_scale() const;

    void set_detail_influence(double p_val);
    double get_detail_influence() const;

    void set_cave_scale(double p_val);
    double get_cave_scale() const;

    void set_cave_density_threshold(double p_val);
    double get_cave_density_threshold() const;
};

}

#endif // TERRAIN_MANAGER_H
