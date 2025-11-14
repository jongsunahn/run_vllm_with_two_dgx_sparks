#!/bin/bash

echo "Deleting FORWARD rules..."
# 5번 규칙 삭제 (순서 중요)
sudo iptables -D FORWARD -d 10.20.0.201 -p tcp --dport 8000 -j ACCEPT
# 4번 규칙 삭제
sudo iptables -D FORWARD -s 10.20.0.201 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "Deleting NAT rules..."
# 3번 규칙 삭제
sudo iptables -t nat -D POSTROUTING -p tcp -d 10.20.0.201 --dport 8000 -j MASQUERADE
# 2번 규칙 삭제
sudo iptables -t nat -D PREROUTING -p tcp -d 192.168.0.22 --dport 8000 -j DNAT --to-destination 10.20.0.201:8000

echo "Done."