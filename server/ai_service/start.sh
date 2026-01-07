#!/bin/bash

# Startup script for Vedic Mate AI Service

echo "🚀 Starting Vedic Mate AI Service..."

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    echo "📦 Activating virtual environment..."
    source venv/bin/activate
fi

# Install dependencies if needed
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from example..."
    cp .env.example .env
    echo "📝 Please edit .env file with your configuration"
fi

# Start the service
echo "🌟 Starting AI Service..."
export FLASK_APP=app.py
export FLASK_ENV=production

# Use Gunicorn for production
if command -v gunicorn &> /dev/null; then
    echo "✅ Starting with Gunicorn..."
    gunicorn -w 4 -b 0.0.0.0:5000 --timeout 120 app:app
else
    echo "⚠️  Gunicorn not found. Starting with Flask development server..."
    python app.py
fi

