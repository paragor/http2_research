#!/bin/sh

set -ex

rp=`realpath $0`
BASE_DIR=`dirname $rp`

server_cubic() {
  sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo sysctl -w net.core.default_qdisc=fq_codel
  sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
  sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo sysctl -w net.ipv4.tcp_notsent_lowat=4294967295
  echo "bbr off"
}
server_bbr() {
  sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo sysctl -w net.core.default_qdisc=fq
  sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
  sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo sysctl -w net.ipv4.tcp_notsent_lowat=16384
  echo "bbr on"
}
client_cubic() {
  sudo sysctl -w net.core.default_qdisc=fq_codel
  sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
  sudo sysctl -w net.ipv4.tcp_notsent_lowat=4294967295
  echo "bbr off"
}
client_bbr() {
  sudo sysctl -w net.core.default_qdisc=fq
  sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
  sudo sysctl -w net.ipv4.tcp_notsent_lowat=16384
  echo "bbr on"
}

iperf_run() {
    outdir=`dirname "$1"`
    mkdir -p "$outdir"
    rm -rf "$1.json"
    iperf3 -c 192.168.100.10 -p 9090 -N -Z -t 300 -J | tee "$1.json"
}

sudo ssh -o StrictHostKeyChecking=no root@192.168.100.10 sudo iperf3 -s -D -p 9090 -B 0.0.0.0


server_cubic
client_cubic
iperf_run "$BASE_DIR/results_iperf/server_cubic.client_cubic"

server_bbr
client_cubic
iperf_run "$BASE_DIR/results_iperf/server_bbr.client_cubic"

server_bbr
client_bbr
iperf_run "$BASE_DIR/results_iperf/server_bbr.client_bbr"

server_cubic
client_bbr
iperf_run "$BASE_DIR/results_iperf/server_cubic.client_bbr"
