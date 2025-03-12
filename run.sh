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

# Set up isolated environment
WORK_DIR="$HOME/Library/Application Support/owl_workspace"
mkdir -p "$WORK_DIR"
chmod 700 "$WORK_DIR"

# Copy files to workspace
cp -r camelAiOwl "$WORK_DIR/"
cp .env "$WORK_DIR/camelAiOwl/"

# Install Python dependencies in isolated environment
if [ ! -d "$WORK_DIR/camelAiOwl/.venv" ]; then
    echo "Installing Python dependencies..."
    cd "$WORK_DIR/camelAiOwl" && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
    cd - > /dev/null
fi

# Run the script
if [ "$1" == "web" ]; then
    echo "Starting web interface..."
    cd "$WORK_DIR/camelAiOwl" && source .venv/bin/activate && python run_app_en.py
else
    echo "Starting CLI interface..."
    cd "$WORK_DIR/camelAiOwl" && source .venv/bin/activate && python run.py "What is artificial intelligence?"
fi
