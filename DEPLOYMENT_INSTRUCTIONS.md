# Deployment Instructions

## 1. Deploy Admin Panel (Production Server)

Run these commands on your EC2 server (`ubuntu@15.207.36.26`):

```bash
# SSH into server
ssh ubuntu@15.207.36.26

# Navigate to project
cd ~/vedicmate

# Pull latest changes
git pull

# Go to admin folder
cd admin

# Stop admin panel
pm2 stop vedicmate-admin

# Clean build cache
rm -rf .next node_modules/.cache

# Install dependencies
npm install --production

# Build
npm run build

# Start admin panel
pm2 start vedicmate-admin

# Save PM2 config
pm2 save

# Verify it's running
pm2 logs vedicmate-admin --lines 20
```

After deployment, visit: `https://15.207.36.26:3000`

## 2. Add ₹50 Bonus to All Accounts

Run this SQL script in your Supabase SQL Editor:

**File:** `supabase_migrations/add_50_bonus_to_all.sql`

This will:
- Add ₹50 to all wallets that haven't received a signup bonus
- Create transaction records for each bonus
- Skip wallets that already have a bonus
- Include the demo account (`demo@vedicmate.com`)

To run:
1. Go to Supabase Dashboard → SQL Editor
2. Copy the contents of `supabase_migrations/add_50_bonus_to_all.sql`
3. Paste and execute
4. Check the output for confirmation

## 3. Recent Changes

### Flutter App:
- ✅ **Remedies Page**: Now shows "Coming Soon" message instead of products
- ✅ **Custom Booking**: Payment button replaced with "Coming Soon"
- ✅ **Build Errors**: Fixed all compilation errors
  - Added missing imports
  - Fixed type conflicts
  - Fixed syntax errors
- ✅ **Supabase URLs**: Changed from `.co` to `.com`

### Admin Panel:
- ✅ **API Connection**: All pages now use Next.js proxy (`/api/*`) instead of direct backend URLs
- ✅ **Health Check**: Fixed to use proxy, avoiding CORS issues
- ✅ **Server Status**: Should now show "Online" after rebuild

## 4. Verify Everything Works

### Admin Panel:
1. Visit `https://15.207.36.26:3000`
2. Login with admin credentials
3. Check server status (bottom left) - should show "Online"
4. Navigate to Products, Orders, Custom Requests - all should load data

### Mobile App:
1. Build and install latest version
2. Login as guest or demo account
3. Check wallet balance - should have ₹50 bonus
4. Go to Remedies - should see "Coming Soon"
5. Go to Custom Booking - button should say "Coming Soon"

## 5. Troubleshooting

### Admin Panel Still Offline:
- Hard refresh browser (Cmd+Shift+R or Ctrl+Shift+R)
- Clear browser cache
- Check PM2 logs: `pm2 logs vedicmate-admin`
- Verify backend is running: `curl http://localhost:3001/api/health`

### Bonus Not Added:
- Check Supabase SQL Editor for errors
- Verify RLS policies allow updates to wallets and transactions tables
- Check transaction records: `SELECT * FROM transactions WHERE description LIKE '%Bonus%'`

### Flutter Build Issues:
- Run `flutter clean && flutter pub get`
- Run `flutter analyze` to check for errors
- Check specific error messages in build output
