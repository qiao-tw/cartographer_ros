#!/usr/bin/env python

import sys
import os
import argparse
from fnmatch import fnmatchcase

from rosbag import Bag


def RewriteMsg(msg):
    if hasattr(msg, "header"):
        if msg.header.frame_id.startswith("/"):
            msg.header.frame_id = msg.header.frame_id[1:]
    if hasattr(msg, "child_frame_id"):
        if msg.child_frame_id.startswith("/"):
            msg.child_frame_id = msg.child_frame_id[1:]
    if hasattr(msg, "transforms"):
        for transform_msg in msg.transforms:
            RewriteMsg(transform_msg)


def main():
    parser = argparse.ArgumentParser(
        description='Merge and patch one or more bags.')
    parser.add_argument('outputbag', help='output bag file with topics merged')
    parser.add_argument('inputbag', nargs='+', help='input bag files')

    args = parser.parse_args()

    topics = [
        '/points_raw', '/esr_can0_tracks', '/esr_can1_tracks',
        '/esr_can2_tracks', '/imu/data', '/fix'
    ]

    total_included_count = 0
    total_skipped_count = 0

    with Bag(args.outputbag, 'w') as o:
        for ifile in args.inputbag:
            matchedtopics = []
            included_count = 0
            skipped_count = 0
            print("> Reading bag file: " + ifile)
            with Bag(ifile, 'r') as ib:
                for topic, msg, t in ib:
                    if any(fnmatchcase(topic, pattern) for pattern in topics):
                        if not topic in matchedtopics:
                            matchedtopics.append(topic)
                            print("Including matched topic '%s'" % topic)
                        RewriteMsg(msg)
                        o.write(topic, msg, msg.header.stamp
                                if msg._has_header else t)
                        included_count += 1
                    else:
                        skipped_count += 1
            total_included_count += included_count
            total_skipped_count += skipped_count
            print("< Included %d messages and skipped %d" % (included_count,
                                                             skipped_count))

        print("Total: Included %d messages and skipped %d" %
              (total_included_count, total_skipped_count))


if __name__ == "__main__":
    main()
