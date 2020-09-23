from datetime import datetime
from statistics import *
import sys


def load_timestamps(trans_file, recv_file, cmd_prefix, trans_delim, recv_delim):
    trans_fp = open(trans_file)
    recv_fp = open(recv_file)
    cmd_dict = {}

    for trans_line in trans_fp.readlines():
        if cmd_prefix not in trans_line:
            continue
        cmd_args = trans_line.split(cmd_prefix)[1]
        cmd_num = cmd_args.split(",")[0]
        time_stamp = trans_line.split(trans_delim)[0]
        time_fmt = time_stamp.strip(" []")
        trans_time = datetime.strptime(time_fmt, '%H:%M:%S.%f')
        print("Trans Stamp " + cmd_num + " " + time_fmt)
        cmd_dict[cmd_num] = []
        cmd_dict[cmd_num].append(trans_time)

    for recv_line in recv_fp.readlines():
        if cmd_prefix not in recv_line:
            continue
        cmd_args = recv_line.split(cmd_prefix)[1]
        cmd_num = cmd_args.split(",")[0]
        time_stamp = recv_line.split(recv_delim)[0]
        time_fmt = time_stamp.strip(" []")
        recv_time = datetime.strptime(time_fmt, '%H:%M:%S.%f')
        print("Recv Stamp " + cmd_num + " " + time_fmt)
        cmd_dict[cmd_num].append(recv_time)

    return cmd_dict


def calculate_latencies(cmd_dict):
    latency_dict = {}
    for cmd_num, time_pair in cmd_dict.items():
        delta = time_pair[1] - time_pair[0]
        elapsed_secs = delta.microseconds / 1000000.0
        latency_dict[cmd_num] = elapsed_secs

    return latency_dict


if __name__ == "__main__":

    ts_dict = load_timestamps("transmission_times.txt", "recieving_times.txt", "C:", "]", "->")
    lat_dict = calculate_latencies(ts_dict)

    # Print out latencies
    print("\n\n=== Command Latencies ===")
    for cmd, latency in lat_dict.items():
        print("Command: " + cmd + " -> Latency: " + str(latency) + "s")
        #print(str(latency))

    latencies = lat_dict.values()
    print("\n\n=== Latency Stats ===")
    print("Mean: " + str(mean(latencies)))
    print("Median: " + str(median(latencies)))
    print("Stdev: " + str(stdev(latencies)))
    print("\n")
