vllm serve openai/gpt-oss-120b \
  --tensor-parallel-size 2 \
  --distributed-executor-backend ray \
  --async-scheduling