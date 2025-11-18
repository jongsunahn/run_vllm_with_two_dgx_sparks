ARG BASE_IMAGE
FROM ${BASE_IMAGE}

USER root

# 1. 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    iproute2 \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace