#!/bin/env bash

# 0. 설정 변수
PHY_IFACE="enp1s0f0np0"   # 호스트의 물리 인터페이스 이름
HOST_SIM_IP="10.20.0.200" # 호스트가 사용할 가상 IP (Gateway 역할)

# 1. (기존) vlan-host 인터페이스 생성 및 IP 할당
sudo ip link add vlan-host link $PHY_IFACE type macvlan mode bridge
sudo ip addr add $HOST_SIM_IP/16 dev vlan-host
sudo ip link set vlan-host up

# 2. (기존) 컨테이너 경로 추가 (대역 전체를 라우팅)
sudo ip route add 10.20.0.0/24 dev vlan-host

# --- ⬇️ [추가된 핵심] 인터넷 공유 설정 ⬇️ ---

# 3. IP 포워딩 활성화 (트래픽 전달 허용)
sudo sysctl -w net.ipv4.ip_forward=1

# 4. NAT(Masquerade) 설정
# "10.20.0.x 대역에서 온 놈이 외부로 나갈 땐, 호스트의 IP로 위장해서 내보내라"
sudo iptables -t nat -A POSTROUTING -s 10.20.0.0/24 ! -d 10.20.0.0/24 -j MASQUERADE

# 1. 10.20.0.x 대역에서 오는 패킷 허용 (Outbound)
sudo iptables -I FORWARD 1 -s 10.20.0.0/24 -j ACCEPT

# 2. 10.20.0.x 대역으로 가는 패킷 허용 (Inbound)
sudo iptables -I FORWARD 1 -d 10.20.0.0/24 -j ACCEPT

echo ">>> Host is now acting as a Gateway for 10.20.0.x!"