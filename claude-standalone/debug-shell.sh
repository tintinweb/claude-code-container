#!/bin/bash

# Debug Shell - Get a bash shell inside the Docker container
set -e

# Parse arguments
INPUT_DIR=""
DATA_DIR=""

# Process arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            echo "Usage: $0 [INPUT_DIR] [DATA_DIR]"
            echo ""
            echo "Arguments:"
            echo "  INPUT_DIR     Directory to mount as input (default: current directory)"
            echo "  DATA_DIR      Optional data directory to mount"
            echo ""
            echo "Examples:"
            echo "  $0                      # Use current dir as input"
            echo "  $0 ./code ./data        # Specify input and data dirs"
            echo ""
            echo "This script starts a bash shell inside the container for debugging."
            exit 0
            ;;
        *)
            if [[ -z "$INPUT_DIR" ]]; then
                INPUT_DIR="$1"
            elif [[ -z "$DATA_DIR" ]] && [[ -d "$1" ]]; then
                DATA_DIR="$1"
            else
                echo "❌ Unknown argument: $1"
                echo "Use --help for usage information"
                exit 1
            fi
            ;;
    esac
    shift
done

# Set defaults
INPUT_DIR="${INPUT_DIR:-$(pwd)}"

# Validate inputs
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ Error: Input directory '$INPUT_DIR' does not exist"
    exit 1
fi

if [ -z "$CLAUDE_API_KEY" ]; then
    echo "⚠️  Warning: CLAUDE_API_KEY not set."
    echo "   Set it with: export CLAUDE_API_KEY='your-api-key'"
    echo ""
fi

# Create reports directory
mkdir -p reports

# Build Docker run command with same security settings as run_claude.sh
DOCKER_ARGS=(
    "run" "-it" "--rm"
    # Override entrypoint to get bash shell
    "--entrypoint" "bash"
    # Security: Drop all capabilities
    "--cap-drop=ALL"
    # Security: Prevent privilege escalation
    "--security-opt=no-new-privileges:true"
    # Security: Non-executable temp filesystem
    "--tmpfs" "/tmp:noexec,nosuid,size=100m"
    "--tmpfs" "/workspace/temp:noexec,nosuid,size=2g"
    # Security: Limit PIDs to prevent fork bombs
    "--pids-limit=100"
    # Security: Restrict network to external only (no host network access)
    "--network=bridge"
    "--add-host=host.docker.internal:127.0.0.1"
    # Volume mounts
    "-v" "$INPUT_DIR:/workspace/input:ro"
    "-v" "$(pwd)/reports:/workspace/output:rw"
    "-e" "CLAUDE_API_KEY=${CLAUDE_API_KEY:-}"
)

# Add data directory if provided
if [ -n "$DATA_DIR" ]; then
    if [ ! -d "$DATA_DIR" ]; then
        echo "❌ Error: Data directory '$DATA_DIR' does not exist"
        exit 1
    fi
    DOCKER_ARGS+=("-v" "$DATA_DIR:/workspace/data:ro")
    echo "📚 Using reference data from: $DATA_DIR"
fi

echo "🐚 Starting debug shell inside container..."
echo "📁 Input: $INPUT_DIR"
echo "📊 Output: $(pwd)/reports"
echo "🔍 Use this shell to debug the container environment"
echo "   - Claude config: cat ~/.claude.json"
echo "   - MCP servers: ls -la /workspace/mcp-servers/"
echo "   - Test Claude: claude-code --help"
echo ""

# Run the container with bash shell
docker "${DOCKER_ARGS[@]}" claude-code-container
