#!/bin/bash

# Interactive Claude Code Shell (Chonky)
set -e

# Collect all arguments to pass to Claude
CLAUDE_ARGS=("$@")

# Fixed paths - no argument parsing needed
INPUT_DIR="$(pwd)"

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
    "-e" "CLAUDE_CODE_OAUTH_TOKEN=${CLAUDE_CODE_OAUTH_TOKEN:-}"
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

echo "🚀 Starting Claude Code in interactive mode (Chonky)..."
echo "� Configuration: claude-config.chonky.json"
echo "�📁 Input: $INPUT_DIR"
echo "📊 Output: $(pwd)/reports"
if [[ ${#CLAUDE_ARGS[@]} -gt 0 ]]; then
    echo "🔧 Claude options: ${CLAUDE_ARGS[*]}"
fi
echo ""

# Run the container with Claude Code in interactive mode, passing through any additional arguments
docker "${DOCKER_ARGS[@]}" claude-code-container-chonky "${CLAUDE_ARGS[@]}"
