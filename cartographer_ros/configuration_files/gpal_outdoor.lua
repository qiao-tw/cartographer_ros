-- Copyright 2018 The GeomatricalPAL Authors
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
  num_point_clouds = 1, -- 2,
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

MAP_BUILDER.use_trajectory_builder_3d = true
MAP_BUILDER.num_background_threads = 14
POSE_GRAPH.optimization_problem.log_solver_summary = false
POSE_GRAPH.constraint_builder.log_matches = true
POSE_GRAPH.log_residual_histograms = false

----------------
-- local SLAM --
----------------
MAX_3D_RANGE = 80.

TRAJECTORY_BUILDER_3D.num_accumulated_range_data = 1 -- we got 360 degree view, no need to accumulate range data
TRAJECTORY_BUILDER_3D.min_range = 2.
TRAJECTORY_BUILDER_3D.max_range = MAX_3D_RANGE
TRAJECTORY_BUILDER_3D.imu_gravity_time_constant = 9.8
TRAJECTORY_BUILDER_3D.submaps.high_resolution = 0.5 -- 0.5 -- fast, rough
TRAJECTORY_BUILDER_3D.submaps.high_resolution_max_range = 40.
TRAJECTORY_BUILDER_3D.submaps.low_resolution = 1.0 -- 0.2
TRAJECTORY_BUILDER_3D.submaps.num_range_data = 60 -- default(160)
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.hit_probability = 0.9
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.miss_probability = 0.49
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.num_free_space_voxels = 0
TRAJECTORY_BUILDER_3D.use_online_correlative_scan_matching = false -- true -- enable it will make SLAM terribly slow

TRAJECTORY_BUILDER_3D.ceres_scan_matcher.occupied_space_weight_0 = 1. -- 1e2 -- default(1.)
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.occupied_space_weight_1 = 6. -- 1e2 -- default(6.)
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.translation_weight = 5. -- default(5.)
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.rotation_weight = 4e1 -- default(4e2)
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.only_optimize_yaw = false

-----------------
-- global SLAM --
-----------------
-- set 0 to turn off global SLAM
POSE_GRAPH.optimize_every_n_nodes = 64
POSE_GRAPH.global_constraint_search_after_n_seconds = 0 -- 5 -- 0
POSE_GRAPH.optimization_problem.fix_first_submap_in_3d = false
POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 50

-- GPS (fixed frame pose)
POSE_GRAPH.optimization_problem.fixed_frame_constraint_to_submap = false
POSE_GRAPH.optimization_problem.fixed_frame_pose_translation_xy_weight = 5e1 -- 1
POSE_GRAPH.optimization_problem.fixed_frame_pose_translation_z_weight = 1e2 -- 1
POSE_GRAPH.optimization_problem.fixed_frame_pose_rotation_yaw_weight = 0
POSE_GRAPH.optimization_problem.fixed_frame_pose_rotation_roll_pitch_weight = 0

-- constraints based on IMU observations of angular velocities and linear acceleration.
POSE_GRAPH.optimization_problem.huber_scale = 1e1 -- default(1e1)
POSE_GRAPH.optimization_problem.acceleration_weight = 1e2 -- 1e3 -- default(1e3)
POSE_GRAPH.optimization_problem.rotation_weight = 3e5 -- default(3e5)

-- intra- and inter-submap constraints
POSE_GRAPH.global_sampling_ratio = 0.1 -- 0.01
POSE_GRAPH.constraint_builder.sampling_ratio = 0.3 -- default(0.3) -- the lower, the faster
-- NOTE: only MatchFullSubmap apply following params
POSE_GRAPH.constraint_builder.max_constraint_xy_distance = 500
POSE_GRAPH.constraint_builder.max_constraint_z_distance = 30
POSE_GRAPH.constraint_builder.max_constraint_angular_search_window = math.rad(30.)
-- intra-submap
POSE_GRAPH.matcher_translation_weight = 5e5 -- default(1e3)
POSE_GRAPH.matcher_rotation_weight = 5e3 -- default(1e3)
-- inter-submap
POSE_GRAPH.constraint_builder.loop_closure_translation_weight = 1e9 -- default(1.1e4)
POSE_GRAPH.constraint_builder.loop_closure_rotation_weight = 1e10 -- default(1e5)

POSE_GRAPH.constraint_builder.ceres_scan_matcher_3d.occupied_space_weight_0 = 1e5 -- default(5.)
POSE_GRAPH.constraint_builder.ceres_scan_matcher_3d.occupied_space_weight_1 = 2e5 -- default(30.)
POSE_GRAPH.constraint_builder.ceres_scan_matcher_3d.translation_weight = 100.
POSE_GRAPH.constraint_builder.ceres_scan_matcher_3d.rotation_weight = 100. -- 10.
POSE_GRAPH.constraint_builder.ceres_scan_matcher_3d.only_optimize_yaw = false

POSE_GRAPH.constraint_builder.global_localization_min_score = 0.3 -- 0.66
POSE_GRAPH.constraint_builder.min_score = 0.55 -- for fast correlative scan matcher, fast, rough
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.min_rotational_score = 0.80
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.min_low_resolution_score = 0.45
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.linear_xy_search_window = 50.
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.linear_z_search_window = 50.
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.angular_search_window = math.rad(30.)


return options
