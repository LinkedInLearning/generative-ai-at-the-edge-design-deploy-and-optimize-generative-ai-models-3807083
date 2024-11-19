#!/bin/bash

# Cleanup all project files
echo -e "Starting project cleanup function\n"
# Clean up models folder
rm -rf /tmp/models
echo "--> Models folder clean-up sucessfull"

# Cleanup docker containers
docker rmi --force `docker images | grep llama.cpp| awk '{print $3}'`
echo "--> Docker containers clean-up sucessfull"

# Clean up github repo files
rm -rf /tmp/generative-ai-at-the-edge-design-deploy-and-optimize-generative-ai-models-3807083
echo "--> Github repo folder clean-up successfull"

echo "CLEANUP COMPLETED