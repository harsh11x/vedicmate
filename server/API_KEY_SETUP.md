# API Key Configuration

## Gemini API Key Setup

Your Gemini API key has been configured:

**API Key:** `AIzaSyD5xwXaJbKIq_HzDSFhHY3ZaLQ_FvjS4Xw`  
**Project Name:** Vedic Mate  
**Project Number:** 933572591660  
**Project ID:** projects/933572591660

## Server Configuration

Create a `.env` file in the `server/` directory with:

```env
PORT=4000
HOST=0.0.0.0
GEMINI_API_KEY=AIzaSyD5xwXaJbKIq_HzDSFhHY3ZaLQ_FvjS4Xw
```

## Flutter App Configuration

The Flutter app's Gemini config has been updated with your API key in:
`lib/core/config/gemini_config.dart`

## Security Note

⚠️ **Important:** The `.env` file is in `.gitignore` to prevent committing API keys to version control.

For production:
1. Use environment variables
2. Use secure key management (AWS Secrets Manager, etc.)
3. Never commit API keys to git

## Testing

After setting up the `.env` file, test the server:

```bash
cd server
npm install
npm run dev
```

Then test the AI endpoint:
```bash
curl -X POST http://localhost:4000/api/ai/welcome \
  -H "Content-Type: application/json" \
  -d '{"panditId":"ai_pandit_1"}'
```

You should receive a welcome message from the AI!

