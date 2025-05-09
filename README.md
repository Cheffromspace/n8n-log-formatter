# n8n Log Formatter

A colorized n8n event log formatter for monitoring AI workflow executions in real-time.

## Overview

This tool allows you to format n8n event logs with a focus on AI-related events. It connects to a remote n8n instance running in Docker and displays workflow execution events with color-coded formatting for improved readability.

## Features

- Real-time log monitoring via SSH and Docker
- Color-coded event visualization
- Two display modes:
  - **Full view**: Complete AI responses with detailed information
  - **Compact view**: Summarized AI responses for a more condensed output
- Highlights workflow successes, failures, node executions, and AI responses

## Prerequisites

- SSH access to the host running n8n Docker container
- Docker container with n8n running
- JQ installed on your local system

## Configuration

Edit the script to adjust these configuration variables:

```bash
SSH_USER="username"        # SSH username for the remote host
SSH_HOST="your-server"     # IP address or hostname of the remote server
DOCKER_CONTAINER="container-id"  # Docker container ID or name
LOG_PATH="/home/node/.n8n/n8nEventLog.log"  # Path to the log file inside the container
```

## Usage

```bash
# Show help information
./format-n8n-log.sh -h
./format-n8n-log.sh --help

# Use compact view (summarized AI responses)
./format-n8n-log.sh -c
./format-n8n-log.sh --compact

# Use full view (complete AI responses)
./format-n8n-log.sh -f
./format-n8n-log.sh --full
```

The default view is full. Press Ctrl+C to exit the formatter.

## Display Format

The formatter displays the following event types:

- 🤖 **AI Responses**: Output from AI nodes
- ▶️ **Node Started**: When a node begins execution
- ✅ **Workflow Success**: Successful workflow executions
- ❌ **Workflow Failed**: Failed workflow executions

Each event includes timestamps, node names, workflow names, and execution IDs where applicable.

## License

[MIT License](LICENSE)