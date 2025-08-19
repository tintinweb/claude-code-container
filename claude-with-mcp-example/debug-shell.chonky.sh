#!/bin/bash

# Get a bash shell inside the Docker container (Chonky Version)
set -e

#!/bin/bash

# Debug Shell - Get a bash shell inside the Docker container (Chonky Version)
set -e

# Collect all arguments to pass to Claude
CLAUDE_ARGS=("$@")

# Fixed paths - no argument parsing needed
INPUT_DIR="$(pwd)"
DATA_DIR="workspace/data"

# Validate input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ Error: Current directory '$INPUT_DIR' does not exist"
    exit 1
fi

# Create reports directory
mkdir -p reports

# Build Docker run command with same security settings as run_claude.chonky.sh
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
)

# Add data directory if it exists
if [ -d "$DATA_DIR" ]; then
    DOCKER_ARGS+=("-v" "$DATA_DIR:/workspace/data:ro")
    echo "📚 Using reference data from: $DATA_DIR"
fi

echo "🐚 Starting debug shell inside container (Chonky)..."
echo "📄 Configuration: claude-config.chonky.json"
echo "📁 Input: $INPUT_DIR"
echo "📊 Output: $(pwd)/reports"
if [[ ${#CLAUDE_ARGS[@]} -gt 0 ]]; then
    echo "🔧 Claude options: ${CLAUDE_ARGS[*]}"
fi
echo "🔍 Use this shell to debug the container environment"
echo "   - Claude config: cat ~/.claude.json"
echo "   - MCP servers: ls -la /workspace/mcp-servers/"
echo "   - Test Claude: claude-code --help"
echo ""

# Run the container with bash shell, passing through any arguments
docker "${DOCKER_ARGS[@]}" claude-code-container-chonky "${CLAUDE_ARGS[@]}"
