#!/bin/bash
# Install dependencies and start backend

echo "📦 Installing Python dependencies..."
pip3 install -r requirements.txt

echo ""
echo "🚀 Starting backend server..."
python3 server.py
