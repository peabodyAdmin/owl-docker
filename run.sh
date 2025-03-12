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

# Create a dedicated user for OWL
OWL_USER="owl_user"
OWL_HOME="/home/$OWL_USER"
if ! id "$OWL_USER" &>/dev/null; then
    echo "Creating dedicated user for OWL..."
    sudo useradd -m -s /bin/bash "$OWL_USER"
    sudo usermod -L "$OWL_USER"  # Lock password
fi

# Set up isolated environment
WORK_DIR="$OWL_HOME/owl_workspace"
sudo mkdir -p "$WORK_DIR"
sudo chown "$OWL_USER:$OWL_USER" "$WORK_DIR"
sudo chmod 700 "$WORK_DIR"

# Copy files to workspace
sudo cp -r camelAiOwl "$WORK_DIR/"
sudo cp .env "$WORK_DIR/camelAiOwl/"
sudo chown -R "$OWL_USER:$OWL_USER" "$WORK_DIR/camelAiOwl"

# Install Python dependencies in isolated environment
if [ ! -d "$WORK_DIR/camelAiOwl/.venv" ]; then
    echo "Installing Python dependencies..."
    sudo -u "$OWL_USER" bash -c "cd $WORK_DIR/camelAiOwl && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
fi

# Set up network isolation (optional)
if command -v firejail >/dev/null 2>&1; then
    WRAPPER="firejail --net=eth0 --dns=1.1.1.1 --private=$WORK_DIR --noroot"
else
    WRAPPER="sudo -u $OWL_USER"
fi

# Run the script
if [ "$1" == "web" ]; then
    echo "Starting web interface..."
    $WRAPPER bash -c "cd $WORK_DIR/camelAiOwl && source .venv/bin/activate && python run_app_en.py"
else
    echo "Starting CLI interface..."
    $WRAPPER bash -c "cd $WORK_DIR/camelAiOwl && source .venv/bin/activate && python run.py \"What is artificial intelligence?\""
fi
