#!/bin/bash

# Deploy Admin Panel to Production Server
# This script builds the admin panel and deploys it to the EC2 instance

set -e

echo "🚀 Starting admin panel deployment..."

# 1. Build the admin panel
echo "📦 Building admin panel..."
cd admin
npm run build

# 2. Create deployment package
echo "📁 Creating deployment package..."
cd ..
tar -czf admin-deploy.tar.gz \
  admin/.next \
  admin/public \
  admin/server.js \
  admin/package.json \
  admin/package-lock.json \
  admin/.env.local \
  admin/next.config.ts \
  certs/

# 3. Upload to server
echo "⬆️  Uploading to server..."
SERVER_USER="ubuntu"
SERVER_IP="13.60.233.237"
SERVER_PATH="/home/ubuntu/vedicmate"

scp admin-deploy.tar.gz ${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/

# 4. SSH and deploy
echo "🔧 Deploying on server..."
ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
cd ~/vedicmate
tar -xzf admin-deploy.tar.gz
cd admin
npm install --production
pm2 restart vedicmate-admin
pm2 save
ENDSSH

# 5. Cleanup
echo "🧹 Cleaning up..."
rm admin-deploy.tar.gz

echo "✅ Deployment complete!"
echo "🌐 Admin panel available at: https://13.60.233.237:3000"
