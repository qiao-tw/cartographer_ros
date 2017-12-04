#!/usr/bin/env python
import argparse
from rosbag import Bag
parser = argparse.ArgumentParser(description='Patch ITRI datasets.')
parser.add_argument('infile', metavar='in.bag')
args = parser.parse_args()
outfile = args.infile[:-4] + "-fixed.bag"
print("Writing patched bag file to " + outfile)

FAKE_ACCEL = False
with Bag(outfile, 'w') as fout:
    for topic, msg, t in Bag(args.infile):
        if topic == 'velodyne_points':
            fout.write(topic, msg, t)
        if topic == 'fix':
            msg.header.frame_id = 'base_gps'
            fout.write(topic, msg, t)
        if topic == 'imu/data':
            if msg.header.frame_id[0] == '/':
                msg.header.frame_id = msg.header.frame_id[1:]
            if FAKE_ACCEL or abs(msg.linear_acceleration.z) < 3:
                if not FAKE_ACCEL:
                    print("Gravity seems to be removed! Replacing accelerometer readings with fake values...")
                    FAKE_ACCEL = True
                msg.linear_acceleration.x = 0.0
                msg.linear_acceleration.y = 0.0
                msg.linear_acceleration.z = 9.8
            fout.write(topic, msg, t)

