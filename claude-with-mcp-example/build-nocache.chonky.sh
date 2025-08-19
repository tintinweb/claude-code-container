#!/bin/bash

# Claude Security Container - Build and Run Script

set -e

echo "🔨 Building Claude Code Container (chonky)..."

# Build the container
docker build --no-cache -t claude-code-container-chonky .

echo "✅ Container built successfully!"

echo "📋 Usage examples:"
echo ""
echo "1. Interactive shell:"
echo "   ./run_claude.chonky.sh"
echo ""
echo "Container is ready! Use the scripts above to get started."
