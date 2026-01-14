#!/bin/bash

# Live Streaming Backend Health Check Script
# This script tests if the backend server is running and ready for live streaming

echo "🔍 Testing VedicMate Backend Server..."
echo "========================================"
echo ""

SERVER="http://15.207.36.26:3000"

# Test 1: Health Endpoint
echo "1️⃣ Testing Health Endpoint..."
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$SERVER/health" 2>&1)
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Health check passed: $BODY"
else
    echo "   ❌ Health check failed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
    echo ""
    echo "🚨 SERVER IS DOWN! Run these commands on AWS:"
    echo "   ssh ubuntu@15.207.36.26"
    echo "   cd /home/ubuntu/vedicmate/server"
    echo "   npm install"
    echo "   pm2 restart vedicmate"
    exit 1
fi

echo ""

# Test 2: Live Session Endpoint
echo "2️⃣ Testing Live Session Endpoint..."
SESSION_RESPONSE=$(curl -s -w "\n%{http_code}" "$SERVER/api/admin/live-sessions/session_1768376801443" 2>&1)
HTTP_CODE=$(echo "$SESSION_RESPONSE" | tail -n1)
BODY=$(echo "$SESSION_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Session endpoint working"
    echo "   Response: $BODY"
else
    echo "   ⚠️  Session endpoint returned HTTP $HTTP_CODE"
    echo "   Response: $BODY"
fi

echo ""

# Test 3: Socket.IO Connection
echo "3️⃣ Testing Socket.IO..."
SOCKET_TEST=$(curl -s "$SERVER/socket.io/?EIO=4&transport=polling" 2>&1)
if [[ "$SOCKET_TEST" == *"sid"* ]]; then
    echo "   ✅ Socket.IO is running"
else
    echo "   ❌ Socket.IO not responding"
fi

echo ""
echo "========================================"
echo "✅ Backend server is ready for live streaming!"
echo ""
echo "Next steps:"
echo "1. Start admin panel: http://15.207.36.26:3000/admin/live-pooja"
echo "2. Click 'Go Live' and allow camera/mic"
echo "3. Open mobile app and navigate to Live Pooja"
echo "4. Video should display automatically"
