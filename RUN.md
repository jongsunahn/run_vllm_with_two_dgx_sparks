vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 2 \
  --distributed-executor-backend ray \
  --async-scheduling

vllm serve nvidia/Llama-4-Scout-17B-16E-Instruct-FP4   --config Llama4_Blackwell.yaml   --tensor-parallel-size 2   --max-model-len 8192   --gpu-memory-utilization 0.9 --distributed-executor-backend ray 


ray job submit --working-dir . -- python serve_llama.py

docker swarm join --token SWMTKN-1-5hm0rb5i5phxj4ws6ixftxfwbwks0hcqv93j6py5mwc0xn2m42-1h646xw1q3w5gt4u38s0ivlti 10.20.0.22:2377

docker stack deploy -c $HOME/docker-compose.yml trtllm-multinode


docker node ls --format '{{.ID}}' | xargs -n1 docker node inspect --format '{{ .Status.Addr }}' > ~/openmpi-hostfile
docker cp ~/openmpi-hostfile $(docker ps -q -f name=trtllm-multinode):/etc/openmpi-hostfile

docker stack ps trtllm-multinode
export TRTLLM_MN_CONTAINER=$(docker ps -q -f name=trtllm-multinode)
docker exec $TRTLLM_MN_CONTAINER bash -c 'cat <<EOF > /tmp/extra-llm-api-config.yml
print_iter_log: false
kv_cache_config:
  dtype: "auto"
  free_gpu_memory_fraction: 0.9
cuda_graph_config:
  enable_padding: true
EOF'

export TRTLLM_MN_CONTAINER=$(docker ps -q -f name=trtllm-multinode)

docker exec \
  -e MODEL="hugging-quants/Meta-Llama-3.1-405B-Instruct-AWQ-INT4" \
  -e HF_TOKEN=$HF_TOKEN \
  -e TORCH_CUDA_ARCH_LIST="12.1" \
  -it $TRTLLM_MN_CONTAINER bash -c '
    mpirun -x HF_TOKEN trtllm-llmapi-launch trtllm-serve $MODEL \
      --tp_size 2 \
      --backend pytorch \
      --max_num_tokens 32768 \
      --max_batch_size 1 \
      --extra_llm_api_options /tmp/extra-llm-api-config.yml \
      --port 8000 \
      --host 0.0.0.0'

docker exec \
  -e MODEL="nvidia/Llama-4-Scout-17B-16E-Instruct-FP4" \
  -e HF_TOKEN=$HF_TOKEN \
  -e TORCH_CUDA_ARCH_LIST="12.1" \
  -it $TRTLLM_MN_CONTAINER bash -c '
    mpirun -x HF_TOKEN trtllm-llmapi-launch trtllm-serve $MODEL \
      --tp_size 2 \
      --max_num_tokens 32768 \
      --max_batch_size 4 \
      --extra_llm_api_options /tmp/extra-llm-api-config.yml \
      --port 8000 \
      --host 0.0.0.0'


TORCH_CUDA_ARCH_LIST="12.1" mpirun   -x CPATH \
  -x TORCH_CUDA_ARCH_LIST \
  -x HF_TOKEN \
  trtllm-llmapi-launch trtllm-serve nvidia/Llama-4-Scout-17B-16E-Instruct-FP4 \
      --tp_size 2 \
      --max_num_tokens 32768 \
      --max_batch_size 4 \
      --extra_llm_api_options /tmp/extra-llm-api-config.yml \
      --port 8000 \
      --host 0.0.0.0


# Standard CUDA path
export CUDA_HOME=/usr/local/cuda-13.0

# Add the include directory to CPATH so the compiler finds cuda.h
export CPATH=$CUDA_HOME/include:/usr/include/linux:/usr/local/cuda-13.0/targets/sbsa-linux/include:$CPATH
export C_INCLUDE_PATH=/usr/local/cuda-13.0/targets/sbsa-linux/include:$C_INCLUDE_PATH
# Ensure binaries and libraries are visible
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

--root-user-action=ignore
export TRTLLM_MN_CONTAINER=$(docker ps -q -f name=trtllm-multinode)
pip install --root-user-action=ignore --force-reinstall torch torchvision torchaudio triton --index-url https://download.pytorch.org/whl/cu130

pip install --root-user-action=ignore sgl-kernel --index-url https://docs.sglang.ai/whl/cu130/
pip install --root-user-action=ignore sglang
pip install --root-user-action=ignore --force-reinstall torch torchvision torchaudio triton --index-url https://download.pytorch.org/whl/cu130

docker exec   -e MODEL="nvidia/Qwen3-235B-A22B-FP4"   -e HF_TOKEN=$HF_TOKEN   -it $TRTLLM_MN_CONTAINER bash -c '
    mpirun -x HF_TOKEN trtllm-llmapi-launch trtllm-serve $MODEL \
      --tp_size 2 \
      --backend pytorch \
      --max_num_tokens 32768 \
      --max_batch_size 4 \
      --extra_llm_api_options /tmp/extra-llm-api-config.yml \
      --port 8355 \
      --host 0.0.0.0'
mpirun -x HF_TOKEN \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x CUDA_HOME \
       -x C_INCLUDE_PATH \
       -x CPLUS_INCLUDE_PATH \
       -x TORCH_CUDA_ARCH_LIST \
       -x TRITON_PTXAS_PATH \
      trtllm-llmapi-launch trtllm-serve deepseek-ai/DeepSeek-R1-Distill-Qwen-32B \
      --tp_size 2 \
      --backend pytorch \
      --max_num_tokens 32768 \
      --max_batch_size 4 \
      --extra_llm_api_options /tmp/extra-llm-api-config.yml \
      --port 8355 \
      --host 0.0.0.0

export CUDA_HOME=/usr/local/cuda
export C_INCLUDE_PATH=$CUDA_HOME/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$CUDA_HOME/include:$CPLUS_INCLUDE_PATH
export TORCH_CUDA_ARCH_LIST="12.1"
export TRITON_PTXAS_PATH=$CUDA_HOME/bin/ptxas
export NCCL_DEBUG=INFO
export NCCL_DEBUG_SUBSYS=INIT,NET,GRAPH

mpirun -x HF_TOKEN \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x CUDA_HOME \
       -x C_INCLUDE_PATH \
       -x CPLUS_INCLUDE_PATH \
       -x TORCH_CUDA_ARCH_LIST \
       -x TRITON_PTXAS_PATH \
       -x NCCL_DEBUG \
       -x NCCL_DEBUG_SUBSYS \
      trtllm-llmapi-launch trtllm-serve nvidia/Llama-4-Scout-17B-16E-Instruct-FP4 \
      --tp_size 2 \
      --backend pytorch \
      --max_num_tokens 32768 \
      --max_batch_size 1 \
      --extra_llm_api_options llama-4-scout.yaml \
      --port 8355 \
      --host 0.0.0.0

mpirun -x HF_TOKEN \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x CUDA_HOME \
       -x C_INCLUDE_PATH \
       -x CPLUS_INCLUDE_PATH \
       -x TORCH_CUDA_ARCH_LIST \
       -x TRITON_PTXAS_PATH \
       -x NCCL_DEBUG \
       -x NCCL_DEBUG_SUBSYS \
       -x TIKTOKEN_ENCODINGS_BASE \
      trtllm-llmapi-launch trtllm-serve openai/gpt-oss-120b \
        --tp_size 2 \
        --max_batch_size 1 \
        --host 0.0.0.0 \
        --port 8355 
  
  