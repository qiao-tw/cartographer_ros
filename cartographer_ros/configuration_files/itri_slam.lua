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
  tracking_frame = "base_imu",
  published_frame = "base_link",
  odom_frame = "odom",
  provide_odom_frame = true,
  use_odometry = false,
  use_gps = true,
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
  imu_sampling_ratio = 1.,
  gps_sampling_ratio = 0.04,
}

TRAJECTORY_BUILDER_3D.num_accumulated_range_data = 1
TRAJECTORY_BUILDER_3D.min_range = 2.
-- TRAJECTORY_BUILDER_3D.ceres_scan_matcher.only_optimize_yaw = true
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.translation_weight = 10.
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.rotation_weight = 100.
TRAJECTORY_BUILDER_3D.submaps.high_resolution = 0.2
TRAJECTORY_BUILDER_3D.submaps.high_resolution_max_range = 40.
TRAJECTORY_BUILDER_3D.submaps.low_resolution = 0.8

MAX_3D_RANGE = 80.

MAP_BUILDER.use_trajectory_builder_3d = true
MAP_BUILDER.num_background_threads = 7
POSE_GRAPH.optimization_problem.huber_scale = 5e2
POSE_GRAPH.optimize_every_n_nodes = 320

-- "global" is over multiple trajectories
POSE_GRAPH.global_sampling_ratio = 0.003 
POSE_GRAPH.global_constraint_search_after_n_seconds = 10.
POSE_GRAPH.constraint_builder.global_localization_min_score = 0.5

-- "local" is within the same trajectory
POSE_GRAPH.constraint_builder.sampling_ratio = 0.03
POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 10
POSE_GRAPH.constraint_builder.min_score = 0.5 -- 0.62 -- for fast correlative scan matcher

POSE_GRAPH.constraint_builder.max_constraint_distance = 20 -- for local constraints
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.linear_xy_search_window = 20.
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.linear_z_search_window = 20.
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.angular_search_window = math.rad(20.)
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.min_rotational_score = 0.4 -- 0.5
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher_3d.min_low_resolution_score = 0.3


POSE_GRAPH.optimization_problem.fixed_frame_pose_translation_weight = 100
POSE_GRAPH.optimization_problem.fixed_frame_pose_rotation_weight = 0
POSE_GRAPH.optimization_problem.fixed_frame_pose_per_n_nodes = 100
POSE_GRAPH.optimization_problem.log_solver_summary = true

return options
