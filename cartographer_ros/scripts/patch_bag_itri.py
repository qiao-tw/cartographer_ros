#!/usr/bin/env python
import argparse
from rosbag import Bag
parser = argparse.ArgumentParser(description='Patch ITRI datasets.')
parser.add_argument('infile', metavar='in.bag')
args = parser.parse_args()
outfile = args.infile[:-4] + "-fixed.bag"
print("Akita writing patched bag file to " + outfile)

FAKE_ACCEL = False
with Bag(outfile, 'w') as fout:
    for topic, msg, t in Bag(args.infile):
        if topic == '/points_raw':
            fout.write('velodyne_points', msg, t)
        if topic == '/fix':
            msg.header.frame_id = 'base_gps'
            fout.write('fix', msg, t)
        if topic == '/imu/data':
            msg.header.frame_id = 'base_imu'
#            if FAKE_ACCEL or abs(msg.linear_acceleration.z) < 3:
#                if not FAKE_ACCEL:
#                    print("Gravity seems to be removed! Replacing accelerometer readings with fake values...")
#                    FAKE_ACCEL = True
#                msg.linear_acceleration.x = 0.0
#                msg.linear_acceleration.y = 0.0
#                msg.linear_acceleration.z = 9.8
            fout.write('imu/data', msg, t)

