# Admin Panel - Access Information

## Running Status
The admin panel is launching in Chrome browser.

## Access Details

### Login Credentials
- **Email**: `vedicmate2025@gmail.com`
- **Password**: `admin123`

### URL
The admin panel will automatically open in Chrome. If it doesn't, you can access it at:
- Local URL: `http://localhost:XXXXX` (port will be shown in terminal)

## Features Available

### Overview Dashboard
- Active Pandits count
- Total Clients
- Today's Revenue
- Platform Fee earnings

### Pandit Management
- View all Pandits (All/Active/Pending/Blocked)
- Add new Pandits
- Edit Pandit details
- Remove Pandits
- Block/Unblock Pandits temporarily
- View detailed analytics per Pandit:
  - Total calls
  - Call minutes
  - Chat minutes
  - Today's earnings
  - Total earnings

### Live Monitoring
- Monitor active calls and chats in real-time
- View session details
- Safety monitoring

### Rate Management
- Set per-minute rates for each Pandit
- Configure Video Call rates
- Configure Audio Call rates
- Configure Chat rates
- View revenue split (65% Pandit / 35% Platform)

### Settings
- Security settings
- Notification configuration
- System settings

## To Run Manually

```bash
cd /Users/harshdev/Documents/Projects/astroapp
flutter run -d chrome --target=lib/main_admin.dart
```

## Troubleshooting

If the admin panel doesn't open:
1. Check if Chrome is installed
2. Try running manually with the command above
3. Check terminal for any error messages
4. Ensure port is not already in use

## Notes

- The admin panel is optimized for web/desktop use
- All features are fully functional
- Revenue split is set to 65% Pandit / 35% Platform
- Blocked Pandits will see an error screen when they try to access the app

