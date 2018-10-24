-- Copyright 2016 The Cartographer Authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",
  tracking_frame = "imu",
  published_frame = "base_link",
  odom_frame = "odom",
  provide_odom_frame = true,
  publish_frame_projected_to_2d = false,
  use_pose_extrapolator = true,
  use_odometry = false,
  use_nav_sat = true,
  use_landmarks = false,
  num_laser_scans = 0,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 1,
  lookup_transform_timeout_sec = 0.2,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 5e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1.,
  unique_ecef_to_local_frame = true,
}

MAX_3D_RANGE = 80.

TRAJECTORY_BUILDER_3D.num_accumulated_range_data = 1 -- we got 360 degree view, no need to accumulate range data
TRAJECTORY_BUILDER_3D.min_range = 2.
TRAJECTORY_BUILDER_3D.max_range = MAX_3D_RANGE
TRAJECTORY_BUILDER_3D.imu_gravity_time_constant = 9.8
TRAJECTORY_BUILDER_3D.submaps.high_resolution = 0.5 -- fast, rough
-- TRAJECTORY_BUILDER_3D.submaps.high_resolution = 0.25 -- slow, meticulous
TRAJECTORY_BUILDER_3D.submaps.high_resolution_max_range = 60.
TRAJECTORY_BUILDER_3D.submaps.low_resolution = 2.0
TRAJECTORY_BUILDER_3D.submaps.num_range_data = 40 -- default(160)
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.hit_probability = 0.8 -- default(0.55)
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.miss_probability = 0.49 -- default(0.49)
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.num_free_space_voxels = 2
TRAJECTORY_BUILDER_3D.use_online_correlative_scan_matching = false -- true -- enable it will make SLAM terribly slow

MAP_BUILDER.use_trajectory_builder_3d = true
MAP_BUILDER.num_background_threads = 14

POSE_GRAPH.optimize_every_n_nodes = 16 -- turn off global SLAM to not mess with tuning
POSE_GRAPH.global_sampling_ratio = 0.001
POSE_GRAPH.log_residual_histograms = false
POSE_GRAPH.optimization_problem.huber_scale = 5e2
POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 50
POSE_GRAPH.optimization_problem.fixed_frame_constraint_to_submap = false
POSE_GRAPH.optimization_problem.fixed_frame_pose_translation_xy_weight = 1000
POSE_GRAPH.optimization_problem.fixed_frame_pose_translation_z_weight = 100
POSE_GRAPH.optimization_problem.fixed_frame_pose_rotation_yaw_weight = 0
POSE_GRAPH.optimization_problem.fixed_frame_pose_rotation_roll_pitch_weight = 0
POSE_GRAPH.optimization_problem.log_solver_summary = false
POSE_GRAPH.global_constraint_search_after_n_seconds = 0

POSE_GRAPH.constraint_builder.log_matches = true

POSE_GRAPH.constraint_builder.sampling_ratio = 0.001 -- the lower, the faster
POSE_GRAPH.constraint_builder.global_localization_min_score = 0.45 -- default(0.6)
POSE_GRAPH.constraint_builder.min_score = 0.4 -- default(0.55) for fast correlative scan matcher, fast, rough
POSE_GRAPH.constraint_builder.max_constraint_xy_distance = 200 -- default(15)
POSE_GRAPH.constraint_builder.max_constraint_z_distance = 20
POSE_GRAPH.constraint_builder.max_constraint_angular_search_window = math.rad(30.)
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.min_rotational_score = 0.77 -- default(0.77)
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.min_low_resolution_score = 0.45 -- default(0.55)
POSE_GRAPH.constraint_builder.loop_closure_translation_weight = 1e7 -- default(1.1e4)
POSE_GRAPH.constraint_builder.loop_closure_rotation_weight = 1e7 -- default(1e5)

return options
