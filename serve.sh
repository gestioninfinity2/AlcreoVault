#!/bin/bash
echo "╔══════════════════════════════════════╗"
echo "║   AlcreoVault — Local Server         ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js not installed."
    echo "Download from: https://nodejs.org"
    exit 1
fi

echo "Starting local server..."
echo "Open your browser at: http://localhost:3000"
echo "Press Ctrl+C to stop."
echo ""
npx --yes serve . -p 3000
