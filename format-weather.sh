#!/bin/bash

# Script name: n8n-log-viewer.sh
# Description: Colorized n8n event log viewer for AI workflow monitoring

# Configuration variables - adjust these as needed
SSH_USER="jonflatt"
SSH_HOST="192.168.1.2"
DOCKER_CONTAINER="abe89595fc2a"
LOG_PATH="/home/node/.n8n/n8nEventLog.log"

# Help function
show_help() {
    echo "n8n Log Viewer"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --compact  Use compact view (summarized AI responses)"
    echo "  -f, --full     Use full view (complete AI responses)"
    echo ""
    echo "Default view is full. Press Ctrl+C to exit."
}

# Parse command line arguments
VIEW_MODE="full"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--compact)
            VIEW_MODE="compact"
            shift
            ;;
        -f|--full)
            VIEW_MODE="full"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# JQ filter for full view
FULL_VIEW_FILTER='
def format_time:
  ((.ts | split("T")[1] | split(".")[0]) + " ");

if .__type == "$$EventMessageAiNode" then
  "\u001b[90m" + format_time + "\u001b[0m" + 
  "\u001b[1;36m🤖 AI RESPONSE\u001b[0m | \u001b[33m" + .payload.nodeName + "\u001b[0m | \u001b[35m" + .payload.workflowName + "\u001b[0m\n" +
  "\u001b[92m" + (.payload.msg | fromjson | .response.response.generations[0][0].text) + "\u001b[0m\n"
elif .__type == "$$EventMessageNode" and .eventName == "n8n.node.started" then
  "\u001b[90m" + format_time + "\u001b[0m" +
  "\u001b[1;34m▶️ NODE STARTED\u001b[0m | \u001b[33m" + .payload.nodeName + "\u001b[0m | \u001b[35m" + .payload.workflowName + "\u001b[0m"
elif .__type == "$$EventMessageWorkflow" and .eventName == "n8n.workflow.success" then
  "\u001b[90m" + format_time + "\u001b[0m" +
  "\u001b[1;32m✅ WORKFLOW SUCCESS\u001b[0m | \u001b[35m" + .payload.workflowName + "\u001b[0m | ID: \u001b[33m" + .payload.executionId + "\u001b[0m"
elif .__type == "$$EventMessageWorkflow" and .eventName == "n8n.workflow.failed" then
  "\u001b[90m" + format_time + "\u001b[0m" +
  "\u001b[1;31m❌ WORKFLOW FAILED\u001b[0m | \u001b[35m" + .payload.workflowName + "\u001b[0m | ID: \u001b[33m" + .payload.executionId + "\u001b[0m"
else
  empty
end'

# JQ filter for compact view
COMPACT_VIEW_FILTER='
def format_time:
  ((.ts | split("T")[1] | split(".")[0]));

if .__type == "$$EventMessageAiNode" then
  "\u001b[90m" + format_time + "\u001b[0m" + 
  " \u001b[1;36m🤖\u001b[0m \u001b[33m" + .payload.nodeName + "\u001b[0m » \u001b[92m" + 
  (.payload.msg | fromjson | .response.response.generations[0][0].text | split("\n")[0:3] | join(" | ")) + "...\u001b[0m"
elif .__type == "$$EventMessageNode" and .eventName == "n8n.node.started" then
  "\u001b[90m" + format_time + "\u001b[0m" +
  " \u001b[1;34m▶️\u001b[0m \u001b[33m" + .payload.nodeName + "\u001b[0m » \u001b[35m" + .payload.workflowName + "\u001b[0m"
elif .__type == "$$EventMessageWorkflow" and .eventName == "n8n.workflow.success" then
  "\u001b[90m" + format_time + "\u001b[0m" +
  " \u001b[1;32m✅\u001b[0m \u001b[35m" + .payload.workflowName + "\u001b[0m (\u001b[33m" + .payload.executionId + "\u001b[0m)"
elif .__type == "$$EventMessageWorkflow" and .eventName == "n8n.workflow.failed" then
  "\u001b[90m" + format_time + "\u001b[0m" +
  " \u001b[1;31m❌\u001b[0m \u001b[35m" + .payload.workflowName + "\u001b[0m (\u001b[33m" + .payload.executionId + "\u001b[0m)"
else
  empty
end'

# Select the appropriate filter based on view mode
if [ "$VIEW_MODE" = "compact" ]; then
    JQ_FILTER="$COMPACT_VIEW_FILTER"
    echo "Using compact view. Press Ctrl+C to exit."
else
    JQ_FILTER="$FULL_VIEW_FILTER"
    echo "Using full view. Press Ctrl+C to exit."
fi

# Main command
ssh "$SSH_USER@$SSH_HOST" "docker exec $DOCKER_CONTAINER tail -f $LOG_PATH" | jq -r "$JQ_FILTER"
