#!/bin/bash

# Claude Security Container - Build and Run Script (Chonky Version)

set -e

echo "🔨 Building Claude Code Container (Chonky)..."
echo "📄 Using configuration: claude-config.chonky.json"

# Build the container using Dockerfile.chonky
docker build -f Dockerfile.chonky -t claude-code-container-chonky .

echo "✅ Container built successfully!"

# Create output directory if it doesn't exist
echo "📋 Usage examples:"
echo ""
echo "1. Interactive shell:"
echo "   ./run_claude.chonky.sh"
echo ""
echo "Container is ready! Use the scripts above to get started."
