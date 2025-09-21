#!/bin/bash

# List of models (model_name:tag) to download from Ollama
# I've selected one key version for each model family you listed that is 8B or less.
MODELS=(
    "llama3.1:8b"           # Llama 3.1 8B
    "llama3.2:3b"           # Llama 3.2 3B
    "llama2:7b"             # Llama 2 7B
    "mistral:7b"            # Mistral 7B
    "deepseek-r1:8b"        # DeepSeek-R1 8B
    "qwen3:8b"              # Qwen3 8B
    "qwen2.5:7b"            # Qwen2.5 7B
    "qwen2.5-coder:7b"      # Qwen2.5-Coder 7B
    "gemma:7b"              # Gemma 7B
    "gemma2:2b"             # Gemma 2 2B
    "phi4-mini"             # Phi-4 Mini (3.8B)
    "codellama:7b"          # CodeLlama 7B
    "tinyllama"             # TinyLlama (1.1B)
    "llava:7b"              # LLaVA (Vision) 7B
    "granite3.3:8b"         # Granite 3.3 8B
    "mixtral"               # Mixtral (8x7B) - runs like a medium-sized model
)

OLLAMA_API="http://localhost:11434/api/pull"

echo "Starting download of all supported Ollama models (8B or less)..."
echo "Ollama API endpoint: $OLLAMA_API"
echo "---------------------------------------------------"

for MODEL in "${MODELS[@]}"; do
    echo "Processing model: $MODEL"
    
    # Construct the JSON payload
    PAYLOAD=$(cat <<EOF
{
    "name": "$MODEL",
    "stream": true
}
EOF
)
    
    # Send the cURL request to the Ollama API
    curl -X POST "$OLLAMA_API" \
         -H 'Content-Type: application/json' \
         -d "$PAYLOAD"
         
    # Add a newline for cleaner output after the streaming response
    echo -e "\n--- Download attempt complete for $MODEL ---\n"
done

echo "Script finished. All model pull requests have been sent to Ollama."
