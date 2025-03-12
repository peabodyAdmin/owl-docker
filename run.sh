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

# Build Docker image if needed
if [ ! -f ".docker-cache/built" ]; then
    echo "Building Docker image..."
    ./build_docker.sh
fi

# Run the script
if [ "$1" == "web" ]; then
    echo "Starting web interface..."
    ./run_in_docker.sh run_app_en.py
else
    echo "Starting CLI interface..."
    ./run_in_docker.sh run.py
fi
