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

k6_run() {
  outdir=`dirname "$1"`
  mkdir -p "$outdir"
  rm -rf "$1*.json"
  WORKERS=1 HTTP_VERSION=1 k6 run --summary-export "$1.w1_h1.json" "$BASE_DIR/http.js"
  WORKERS=6 HTTP_VERSION=1 k6 run --summary-export "$1.w6_h1.json" "$BASE_DIR/http.js"
  WORKERS=1 HTTP_VERSION=2 k6 run --summary-export "$1.w1_h2.json" "$BASE_DIR/http.js"
  WORKERS=6 HTTP_VERSION=2 k6 run --summary-export "$1.w6_h2.json" "$BASE_DIR/http.js"
}

rm -rf "$BASE_DIR/results/*.json"
mkdir -p "$BASE_DIR/results"

server_cubic
client_cubic
k6_run "$BASE_DIR/results/server_cubic.client_cubic"

server_bbr
client_cubic
k6_run "$BASE_DIR/results/server_bbr.client_cubic"

server_bbr
client_bbr
k6_run "$BASE_DIR/results/server_bbr.client_bbr"

server_cubic
client_bbr
k6_run "$BASE_DIR/results/server_cubic.client_bbr"
