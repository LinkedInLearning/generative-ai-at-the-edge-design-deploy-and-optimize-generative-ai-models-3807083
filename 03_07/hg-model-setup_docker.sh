#!/bin/bash

# Identify all the prerequisites
function pull() {
  bin1=$(which git)
  if [ -z $bin1 ]
  then
    echo "Git is not installed on this system. Please install and try again"
    exit
  else
    echo -e "Git is installed on this system. Proceeding with setup."
  fi

  git config --global credential.helper store

  ## Authenticate to Huggingface
  echo "Provide your Huggingface Access Token: "
  read HF_ACCESS_TOKEN
  huggingface-cli login --token $HF_ACCESS_TOKEN --add-to-git-credential
  
  ## Pull desired model from hugging face
  if [ -d "/tmp/models" ]
  then
    echo "Model files directory exists. Proceeding with model file pull."
  else
    mkdir /tmp/models
    echo -e "Model files directory has been created. Proceeding with model file pull.\n"
  fi

  echo "What is Model you are trying to download: "
  read MODEL_NAME
  huggingface-cli download $MODEL_NAME --local-dir "/tmp/models" --include "*"

  ## Check that the model pull completed
  if [ -z "$( ls -A '/tmp/models' )" ]
  then
    echo "Model pull was not successful. Please check your logs."
    exit
  else
    echo "Model pull was successful. Thanks."
  fi
}

# Function to setup the Ollama/Open-webui docker container
function convert() {
  bin2=$(which python3)
  bin3=$(which pip3)
  if [ -z $bin2 ]
  then
    echo "Python is not installed on this system. Please install and try again"
    exit
  else
    echo -e "Python is installed on this system. Proceeding with setup."
  fi

  if [ -z $bin3 ]
  then
    echo "Pip is not installed on this system. Please install and try again"
    exit
  else
    echo -e "Pip is installed on this system. Proceeding with setup."
  fi

  echo "Have you run the Pull function? (Y/N): "
  read response
  if [ "$response" == "Y" ] || [ "$response" == "y" ]
  then
    echo "Proceeding with the Pull function."
  elif [ "$response" == "N" ] || [ "$response" == "n" ]
  then
    echo "Please run the Pull function and try again."
    exit
  else
    echo "Please enter the right option."
    main
  fi

  ## setup llama.cpp
  cd /tmp
  git clone https://github.com/ggerganov/llama.cpp.git
  cd llama.cpp
  python3 -m venv .venv
  . .venv/bin/activate
  make
  pip3 install --upgrade pip wheel setuptools
  pip3 install --upgrade -r requirements.txt

  ## Converting the hg model files to gguf format
  touch /tmp/models/Qwen2.5-0.5b-f16.gguf
  docker run --rm -v "/tmp/models":/repo ghcr.io/ggerganov/llama.cpp:full --convert "/repo" --outfile "/repo/Qwen2.5-0.5b-f16.gguf" --outtype f16
  
  echo "Model conversion was successful."
}

# Function to test Ollama/Open-webui docker container
function quantize() {
  echo "Have you run the Pull/Convert function? (Y/N): "
  read response
  if [ "$response" == "Y" ] || [ "$response" == "y" ]
  then
    echo "Proceeding with the Quantization function."
  elif [ "$response" == "N" ] || [ "$response" == "n" ]
  then
    echo "Please run the Pull/Convert function and try again."
    exit
  else
    echo "Please enter the right option."
    main
  fi

  ## Quantize the gguf model files to bin
  docker run --rm -v "/tmp/models":/repo ghcr.io/ggerganov/llama.cpp:full --quantize "/repo/Qwen2.5-0.5b-f16.gguf" "/repo/MyQwen-model-Q4_K_M.bin" "Q4_K_M"
  
  echo "Model Quantization was successful."
  }

# Funtion to perform all actions
function endall() {
  exit
}

# Main function
function main() {
  while true; do
    echo -e "1. Pull Model"
    echo -e "2. Convert Model"
    echo -e "3. Quantize Model"
    echo -e "4. Exit"
    read -p "Choose an option: " choice

    case $choice in
      1)
        pull
        ;;
      2)
        convert
        ;;
      3)
        quantize
        ;;
      4)
        endall
        ;;
      *)
        echo -e "\033[31mInvalid choice. Please try again.\033[0m"
        ;;
    esac
  done
}

# Call the main function
main
