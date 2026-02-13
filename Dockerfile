FROM nvidia/cuda:13.0.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Python 3.12 설치
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# venv 생성 및 활성화
ENV VIRTUAL_ENV=/opt/venv
RUN python3.12 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV VLLM_VERSION=0.15.0
ENV CUDA_VERSION=130
ENV CPU_ARCH=aarch64

RUN pip install --upgrade pip
    # pip install vllm==0.15.0
# RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cu130
RUN pip install https://github.com/vllm-project/vllm/releases/download/v${VLLM_VERSION}/vllm-${VLLM_VERSION}+cu${CUDA_VERSION}-cp38-abi3-manylinux_2_35_${CPU_ARCH}.whl --extra-index-url https://download.pytorch.org/whl/cu${CUDA_VERSION}
RUN pip install torch-c-dlpack-ext
RUN pip install -U "ray[data,train,tune,serve]"
# 작업 디렉토리
WORKDIR /app

# HuggingFace 캐시 디렉토리
ENV HF_HOME=/root/.cache/huggingface
ENV CUDA_VERSION=130
# 기본 포트

COPY ./run.sh /app/run.sh
EXPOSE 8000

# vllm serve 실행
ENTRYPOINT ["vllm", "serve"]
