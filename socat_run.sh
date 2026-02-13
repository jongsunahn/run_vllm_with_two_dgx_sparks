#!/bin/bash

nohup sudo socat TCP-LISTEN:9090,fork,bind=127.0.0.1 TCP:192.168.0.7:9090 &
nohup sudo socat TCP-LISTEN:8000,fork,bind=127.0.0.1 TCP:192.168.0.7:8000 &