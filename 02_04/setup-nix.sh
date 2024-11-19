#!/bin/bash

# Identify all the prerequisites
function checks() {
  bin1=$(which docker)
  bin2=$(which curl)
  if [ -z $bin1 ]
  then
    echo "Docker is not installed. Please install and try again"
    exit
  else
    echo -e "Docker is installed. Proceeding with setup."
  fi

  if [ -z $bin2 ]
  then
    echo "Curl is not installed. Please install and try again"
    exit
  else
    echo -e "Curl is installed. Proceeding with setup.\n"
  fi
}

# Function to setup the Ollama/Open-webui docker container
function setup() {
  echo -e "Setting up Ollama and Open-webui"
  contd=$(docker ps | grep my-open-webui | awk '{print $13}')
  if [ "$contd" == "my-open-webui" ]
  then
    docker stop my-open-webui > /dev/null
    docker rm my-open-webui > /dev/null
    mkdir /tmp/models
    mkdir ~/ollama
    mkdir ~/open-webui
    echo -e "my-open-webui container is `docker run -d -p 3001:8080 -v ~/ollama:/root/.ollama -v ~/open-webui:/app/backend/data --name my-open-webui --restart always ghcr.io/open-webui/open-webui:ollama`\n"
    echo "Ollama/Open-webui container is setup successfully. Access your setup by going to http://localhost:3001"
    echo 'To access the container command line interface, run "docker exec -it my-open-webui bash"'
  else
    echo -e "my-open-webui container is `docker run -d -p 3001:8080 -v ~/ollama:/root/.ollama -v ~/open-webui:/app/backend/data --name my-open-webui --restart always ghcr.io/open-webui/open-webui:ollama`\n"
    echo "Ollama/Open-webui container is setup successfully. Access your setup by going to http://localhost:3001"
    echo 'To access the container command line interface, run "docker exec -it my-open-webui bash"'
  fi
}

# Function to test Ollama/Open-webui docker container
function test() {
  echo "Testing Ollama/Open-webui setup. Please wait."
  sleep 10
  status=$(curl --silent --head localhost:3001 | awk '/^HTTP/{print $2}')
  if [ "$status" == "200" ]
  then
    echo "Ollama/Open-webui is up and healthy"
  else
    echo "Ollama/Open-webui is unhealthy. Please check your setup"
  fi
  echo -e 'To check your setup, verify the status of your my-open-webui container using "docker ps -a"\n'
}

# Funtion to perform all actions
function endall() {
  exit
}

# Main function
function main() {
  while true; do
    echo -e "1. Checks"
    echo -e "2. Setup"
    echo -e "3. Test"
    echo -e "4. Exit"
    read -p "Choose an option: " choice

    case $choice in
      1)
        checks
        ;;
      2)
        setup
        ;;
      3)
        test
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
