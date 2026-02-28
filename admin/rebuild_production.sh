#!/bin/bash

# Rebuild and restart admin panel on production server
# Run this script ON THE SERVER (not locally)

set -e

echo "🚀 Rebuilding admin panel..."

# Stop the admin panel
pm2 stop vedicmate-admin

# Clear old build
rm -rf .next

# Rebuild
npm run build

# Restart
pm2 restart vedicmate-admin
pm2 save

echo "✅ Admin panel rebuilt and restarted!"
echo "🌐 Available at: https://15.207.36.26:3000"

# Show logs
pm2 logs vedicmate-admin --lines 10
