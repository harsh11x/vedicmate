# Admin Panel Deployment Guide

## Quick Deploy (Automated)

If you have SSH access configured:

```bash
./deploy_admin.sh
```

## Manual Deployment Steps

### 1. Build the Admin Panel Locally

```bash
cd admin
npm run build
```

### 2. Create Deployment Package

From the project root:

```bash
tar -czf admin-deploy.tar.gz \
  admin/.next \
  admin/public \
  admin/server.js \
  admin/package.json \
  admin/package-lock.json \
  admin/.env.local \
  admin/next.config.ts \
  certs/
```

### 3. Upload to Server

```bash
scp admin-deploy.tar.gz ubuntu@15.207.36.26:/home/ubuntu/vedicmate/
```

### 4. Deploy on Server

SSH into the server:

```bash
ssh ubuntu@15.207.36.26
```

Then run:

```bash
cd ~/vedicmate
tar -xzf admin-deploy.tar.gz
cd admin
npm install --production
pm2 restart vedicmate-admin
pm2 save
```

### 5. Verify Deployment

Check logs:
```bash
pm2 logs vedicmate-admin
```

Check status:
```bash
pm2 status
```

Visit: https://15.207.36.26:3000

## Troubleshooting

### "Server Action not found" errors
This happens when the production build is out of sync. Solution:
1. Clear the `.next` cache: `rm -rf admin/.next`
2. Rebuild: `npm run build`
3. Redeploy

### Port already in use
```bash
pm2 stop vedicmate-admin
pm2 delete vedicmate-admin
pm2 start npm --name "vedicmate-admin" -- run start:https
pm2 save
```

### Health check still failing
1. Verify backend is running: `curl http://15.207.36.26:3001/api/health`
2. Check proxy configuration in `admin/next.config.ts`
3. Verify `.env.local` has correct `NEXT_PUBLIC_API_BACKEND` value
