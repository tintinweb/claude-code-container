#!/bin/bash

# Claude Security Container - Build and Run Script

set -e

echo "🔨 Building Claude Code Container..."

# Build the container
docker build --no-cache -t claude-code-container .

echo "✅ Container built successfully!"

echo "📋 Usage examples:"
echo ""
echo "1. Interactive shell:"
echo "   ./run_claude.sh"
echo ""
echo "Container is ready! Use the scripts above to get started."
