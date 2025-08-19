#!/bin/bash

# Interactive Claude Code Shell
set -e

# Parse arguments - first two can be INPUT_DIR and DATA_DIR, rest go to Claude
CLAUDE_ARGS=()
INPUT_DIR=""
DATA_DIR=""

# Process arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --x-help|-h)
            echo "Usage: $0 [INPUT_DIR] [DATA_DIR] [CLAUDE_OPTIONS...]"
            echo ""
            echo "Arguments:"
            echo "  INPUT_DIR     Directory to mount as input (default: current directory)"
            echo "  DATA_DIR      Optional data directory to mount"
            echo "  CLAUDE_OPTIONS Any additional options to pass to Claude Code"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Use current dir as input"
            echo "  $0 ./code ./data                     # Specify input and data dirs"
            echo "  $0 ./code --debug                    # Pass --debug to Claude"
            echo "  $0 ./code ./data --model claude-3.5-sonnet  # Specify model"
            exit 0
            ;;
        *)
            if [[ -z "$INPUT_DIR" ]]; then
                INPUT_DIR="$1"
            elif [[ -z "$DATA_DIR" ]] && [[ -d "$1" ]]; then
                DATA_DIR="$1"
            else
                CLAUDE_ARGS+=("$1")
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
    echo "⚠️  Warning: CLAUDE_API_KEY not set. Claude Code may not work properly."
    echo "   Set it with: export CLAUDE_API_KEY='your-api-key'"
    echo ""
fi

# Create reports directory
mkdir -p reports

# Build Docker run command with enhanced security
DOCKER_ARGS=(
    "run" "-it" "--rm"
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

echo "🚀 Starting Claude Code in interactive mode..."
echo "📁 Input: $INPUT_DIR"
echo "📊 Output: $(pwd)/reports"
if [[ ${#CLAUDE_ARGS[@]} -gt 0 ]]; then
    echo "🔧 Claude options: ${CLAUDE_ARGS[*]}"
fi
echo ""

# Run the container with Claude Code in interactive mode, passing through any additional arguments
docker "${DOCKER_ARGS[@]}" claude-code-container "${CLAUDE_ARGS[@]}"
