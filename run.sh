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
