#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "Please edit .env and add your OpenAI API key"
    exit 1
fi

# Initialize and update submodule if needed
if [ ! -d "camelAiOwl" ]; then
    echo "Cloning camelAiOwl repository..."
    git clone https://github.com/peabodyAdmin/camelAiOwl.git
    if [ ! -d "camelAiOwl" ]; then
        echo "Error: Failed to clone camelAiOwl repository"
        exit 1
    fi
fi

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
