#!/bin/bash

vllm serve --model openai/gpt-oss-120b --tensor-parallel-size 2 --enable-auto-tool-choice --tool-call-parser=openai --reasoning-parser=openai_gptoss --distributed-executor-backend ray --api-key XsHAZxkIg6EEId7n51wEfzWlqETIFm7OwnguQbUf1bc=