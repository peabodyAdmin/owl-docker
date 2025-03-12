# OWL Docker Runner

A simple script to run [CAMEL-AI OWL](https://github.com/CAMEL-AI-org/camelAiOwl) in Docker.

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/peabodyAdmin/owl-docker.git
cd owl-docker
```

2. Make the script executable:
```bash
chmod +x run.sh
```

3. Run the script:
```bash
# For CLI interface
./run.sh

# For web interface
./run.sh web
```

The script will:
1. Create a .env file if it doesn't exist
2. Clone the CAMEL-AI OWL repository if needed
3. Copy your .env file to the right location
4. Run the appropriate Docker container

## Environment Variables

Edit `.env` file (created from `.env.example`) and add your OpenAI API key:
```bash
OPENAI_API_KEY=your_openai_api_key_here
LOG_LEVEL=INFO  # Optional
```