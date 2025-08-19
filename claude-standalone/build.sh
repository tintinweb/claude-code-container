#!/bin/bash

# Claude Security Container - Build and Run Script

set -e

echo "🔨 Building Claude Code Container..."

# Build the container
docker build -t claude-code-container .

echo "✅ Container built successfully!"

# Create output directory if it doesn't exist

echo "📋 Usage examples:"
echo ""
echo "1. Interactive shell:"
echo "   ./run_claude.sh"
echo ""
echo "Container is ready! Use the scripts above to get started."
