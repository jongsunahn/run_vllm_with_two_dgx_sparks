#!/bin/env bash

# 1. 'vlan-host'라는 이름의 macvlan 인터페이스 생성
sudo ip link add vlan-host link enp1s0f0np0 type macvlan mode bridge

# 2. 이 가상 인터페이스에 호스트가 사용할 새 IP 할당 (예: 10.20.0.200)
sudo ip addr add 10.20.0.200/32 dev vlan-host

# 3. 인터페이스 활성화
sudo ip link set vlan-host up

# 4. 컨테이너 IP로 가는 경로를 이 가상 인터페이스로 지정
sudo ip route add 10.20.0.201/32 dev vlan-host # Head 컨테이너
sudo ip route add 10.20.0.202/32 dev vlan-host # Worker 컨테이너
