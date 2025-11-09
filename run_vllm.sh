#!/bin/env bash

export VLLM_IMAGE=nvcr.io/nvidia/vllm:25.09-py3
## On Node 1, start head node
export MN_IF_NAME=enp1s0f0np0
bash run_cluster.sh $VLLM_IMAGE 169.254.36.109 --head ~/.cache/huggingface \
-e VLLM_HOST_IP=169.254.36.109 \
-e UCX_NET_DEVICES=$MN_IF_NAME \
-e NCCL_SOCKET_IFNAME=$MN_IF_NAME \
-e OMPI_MCA_btl_tcp_if_include=$MN_IF_NAME \
-e GLOO_SOCKET_IFNAME=$MN_IF_NAME \
-e TP_SOCKET_IFNAME=$MN_IF_NAME \
-e RAY_memory_monitor_refresh_ms=0 \
-e MASTER_ADDR=169.254.36.109
