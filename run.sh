#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "Please edit .env and add your OpenAI API key"
    exit 1
fi

# Initialize and update submodule if needed
if [ ! -d "camelAiOwl" ] || [ ! -f "camelAiOwl/.git" ]; then
    echo "Initializing and updating git submodule..."
    git submodule init
    git submodule update --init --recursive
    if [ ! -d "camelAiOwl" ]; then
        echo "Error: Failed to initialize submodule. Please clone with --recurse-submodules"
        echo "Example: git clone --recurse-submodules https://github.com/peabodyAdmin/owl-docker.git"
        exit 1
    fi
if [ ! -f "camelAiOwl/.git" ]; then
    echo "Initializing git submodule..."
    git submodule init
fi

echo "Updating git submodule..."
git submodule update

# Copy .env to camelAiOwl directory
cp .env camelAiOwl/.env

# Change to camelAiOwl directory and run docker-compose
cd camelAiOwl

# Check if user wants CLI or web interface
if [ "$1" == "web" ]; then
    echo "Starting web interface..."
    docker-compose up owl-web
else
    echo "Starting CLI interface..."
    docker-compose run --rm owl-cli
fi