# 1. 설정된 경로 삭제
sudo ip route del 10.20.0.201/32 dev vlan-host
sudo ip route del 10.20.0.202/32 dev vlan-host

# 2. 인터페이스 비활성화
sudo ip link set vlan-host down

# 3. 인터페이스 삭제
sudo ip link del vlan-host
