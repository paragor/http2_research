#!/bin/sh

set -e

if [ "$(sysctl net.ipv4.tcp_congestion_control -nb)" = "bbr" ]
then
  sysctl -w net.core.default_qdisc=fq_codel
  sysctl -w net.ipv4.tcp_congestion_control=cubic
  sysctl -w net.ipv4.tcp_notsent_lowat=4294967295
  echo "bbr off"
else
  sysctl -w net.core.default_qdisc=fq
  sysctl -w net.ipv4.tcp_congestion_control=bbr
  sysctl -w net.ipv4.tcp_notsent_lowat=16384
  echo "bbr on"
fi

