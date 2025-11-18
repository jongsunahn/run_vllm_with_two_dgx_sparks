#!/bin/bash
echo "==> Cleaning up old rules..."
# --- 기존 8000 포트 규칙 삭제 ---
sudo iptables -D FORWARD -d 10.20.0.202 -p tcp --dport 8000 -j ACCEPT 2>/dev/null
sudo iptables -D FORWARD -s 10.20.0.202 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
sudo iptables -t nat -D POSTROUTING -p tcp -d 10.20.0.202 --dport 8000 -j MASQUERADE 2>/dev/null
sudo iptables -t nat -D OUTPUT -p tcp -d 192.168.0.7 --dport 8000 -j DNAT --to-destination 10.20.0.202:8000 2>/dev/null
sudo iptables -t nat -D PREROUTING -p tcp -d 192.168.0.7 --dport 8000 -j DNAT --to-destination 10.20.0.202:8000 2>/dev/null
# sudo iptables -t nat -D OUTPUT -p tcp -d 127.0.0.1 --dport 8000 -j DNAT --to-destination 10.20.0.202:8000 2>/dev/null

# --- 기존 8265 포트 규칙 삭제 ---
sudo iptables -D FORWARD -d 10.20.0.202 -p tcp --dport 8265 -j ACCEPT 2>/dev/null
sudo iptables -D FORWARD -s 10.20.0.202 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
sudo iptables -t nat -D POSTROUTING -p tcp -d 10.20.0.202 --dport 8265 -j MASQUERADE 2>/dev/null
sudo iptables -t nat -D OUTPUT -p tcp -d 192.168.0.7 --dport 8265 -j DNAT --to-destination 10.20.0.202:8265 2>/dev/null
sudo iptables -t nat -D PREROUTING -p tcp -d 192.168.0.7 --dport 8265 -j DNAT --to-destination 10.20.0.202:8265 2>/dev/null

# --- [추가] 기존 9090 포트 규칙 삭제 ---
sudo iptables -D FORWARD -d 10.20.0.202 -p tcp --dport 9090 -j ACCEPT 2>/dev/null
sudo iptables -D FORWARD -s 10.20.0.202 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
sudo iptables -t nat -D POSTROUTING -p tcp -d 10.20.0.202 --dport 9090 -j MASQUERADE 2>/dev/null
sudo iptables -t nat -D OUTPUT -p tcp -d 192.168.0.7 --dport 9090 -j DNAT --to-destination 10.20.0.202:9090 2>/dev/null
sudo iptables -t nat -D PREROUTING -p tcp -d 192.168.0.7 --dport 9090 -j DNAT --to-destination 10.20.0.202:9090 2>/dev/null
# sudo iptables -t nat -D OUTPUT -p tcp -d 127.0.0.1 --dport 9090 -j DNAT --to-destination 10.20.0.202:9090 2>/dev/null


echo "==> Applying correct rules for vLLM (8000), Dashboard (8265), and Prometheus (9090)..."
# 1. IP 포워딩 활성화
sudo sysctl -w net.ipv4.ip_forward=1

# --- vLLM (Port 8000) 규칙 ---
sudo iptables -t nat -A PREROUTING -p tcp -d 192.168.0.7 --dport 8000 -j DNAT --to-destination 10.20.0.202:8000
sudo iptables -t nat -A OUTPUT -p tcp -d 192.168.0.7 --dport 8000 -j DNAT --to-destination 10.20.0.202:8000
# sudo iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 --dport 8000 -j DNAT --to-destination 10.20.0.202:8000
sudo iptables -t nat -A POSTROUTING -p tcp -d 10.20.0.202 --dport 8000 -j MASQUERADE
sudo iptables -I FORWARD 1 -s 10.20.0.202 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -I FORWARD 1 -d 10.20.0.202 -p tcp --dport 8000 -j ACCEPT

# --- Ray Dashboard (Port 8265) 규칙 ---
sudo iptables -t nat -A PREROUTING -p tcp -d 192.168.0.7 --dport 8265 -j DNAT --to-destination 10.20.0.202:8265
sudo iptables -t nat -A OUTPUT -p tcp -d 192.168.0.7 --dport 8265 -j DNAT --to-destination 10.20.0.202:8265
sudo iptables -t nat -A POSTROUTING -p tcp -d 10.20.0.202 --dport 8265 -j MASQUERADE
sudo iptables -I FORWARD 1 -s 10.20.0.202 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -I FORWARD 1 -d 10.20.0.202 -p tcp --dport 8265 -j ACCEPT

# --- [추가] Prometheus (Port 9090) 규칙 ---
sudo iptables -t nat -A PREROUTING -p tcp -d 192.168.0.7 --dport 9090 -j DNAT --to-destination 10.20.0.202:9090
sudo iptables -t nat -A OUTPUT -p tcp -d 192.168.0.7 --dport 9090 -j DNAT --to-destination 10.20.0.202:9090
# sudo iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 --dport 9090 -j DNAT --to-destination 10.20.0.202:9090
sudo iptables -t nat -A POSTROUTING -p tcp -d 10.20.0.202 --dport 9090 -j MASQUERADE
sudo iptables -I FORWARD 1 -s 10.20.0.202 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -I FORWARD 1 -d 10.20.0.202 -p tcp --dport 9090 -j ACCEPT

echo "==> Done. Rules applied."