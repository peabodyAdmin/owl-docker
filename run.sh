#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "Please edit .env and add your OpenAI API key"
    exit 1
fi

# Clone OWL repository if needed
if [ ! -d "camelAiOwl" ]; then
    echo "Cloning OWL repository..."
    git clone https://github.com/camel-ai/owl.git camelAiOwl
    if [ ! -d "camelAiOwl" ]; then
        echo "Error: Failed to clone OWL repository"
        exit 1
    fi
fi

# Copy .env to camelAiOwl directory
cp .env camelAiOwl/.env

# Copy Docker files and scripts
cp -r camelAiOwl/.container/* .
chmod +x build_docker.sh run_in_docker.sh check_docker.sh

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    if [ "$(uname)" == "Darwin" ]; then
        echo "Please install Docker Desktop for Mac: https://docs.docker.com/desktop/mac/install/"
        exit 1
    elif [ "$(uname)" == "Linux" ]; then
        # Install Docker on Linux
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    else
        echo "Please install Docker for your operating system: https://docs.docker.com/get-docker/"
        exit 1
    fi
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Start Docker daemon if needed
if ! docker info &> /dev/null; then
    echo "Starting Docker daemon..."
    # Install required packages
    sudo apt-get update
    sudo apt-get install -y fuse-overlayfs iptables dbus-user-session
    # Configure rootless Docker
    sudo loginctl enable-linger $USER
    dockerd-rootless-setuptool.sh install
    # Start Docker daemon
    dockerd-rootless.sh > /tmp/docker.log 2>&1 &
    # Wait for Docker to be ready (max 30 seconds)
    for i in {1..30}; do
        if docker info &> /dev/null; then
            break
        fi
        echo "Waiting for Docker to start... ($i/30)"
        sleep 1
    done
    if ! docker info &> /dev/null; then
        echo "Error: Docker failed to start"
        cat /tmp/docker.log
        exit 1
    fi
fi

# Build Docker image if needed
if [ ! -f ".docker-cache/built" ]; then
    echo "Building Docker image..."
    cd camelAiOwl/.container
    chmod +x build_docker.sh run_in_docker.sh check_docker.sh
    sudo DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 ./build_docker.sh
    cd ../..
fi

# Run the script
if [ "$1" == "web" ]; then
    echo "Starting web interface..."
    cd camelAiOwl/.container
    chmod +x run_in_docker.sh
    sudo ./run_in_docker.sh ../run_app_en.py
else
    echo "Starting CLI interface..."
    cd camelAiOwl/.container
    chmod +x run_in_docker.sh
    sudo ./run_in_docker.sh ../run.py "What is artificial intelligence?"
fi
