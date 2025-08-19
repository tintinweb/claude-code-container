#!/bin/bash

# Claude Security Container - Build and Run Script

set -e

echo "🔨 Building Claude Code Container..."

# Build the container
docker build -t claude-code-container .

echo "✅ Container built successfully!"

# Create output directory if it doesn't exist
mkdir -p reports

echo "📋 Usage examples:"
echo ""
echo "1. Interactive shell:"
echo "   ./interactive-shell.sh"
echo ""
echo "2. With custom input directory:"
echo "   ./interactive-shell.sh /path/to/codebase"
echo ""
echo "3. With reference data:"
echo "   ./interactive-shell.sh /path/to/codebase /path/to/reference-data"
echo ""
echo "Container is ready! Use the scripts above to get started."
