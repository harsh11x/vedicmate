# Gemini AI Setup Guide

This guide will help you set up the Gemini AI service with personality-based responses for all AI Pandits.

## Prerequisites

1. A Google account
2. Access to Google AI Studio (makersuite.google.com)

## Step 1: Get Your Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

## Step 2: Configure the API Key

1. Open `lib/core/config/gemini_config.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:

```dart
static const String apiKey = 'your-actual-api-key-here';
```

**Important:** For production apps, consider:
- Using environment variables
- Storing in secure storage (like Flutter Secure Storage)
- Using a backend proxy to hide the API key

## Step 3: Test the Integration

1. Run the app
2. Navigate to any AI Pandit chat
3. Send a message
4. The AI should respond with the pandit's unique personality

## Personality System

Each AI Pandit has been configured with:

- **Unique Speaking Style**: Based on their name, experience, and specializations
- **Expertise Description**: Detailed knowledge of their specialization areas
- **Personality Traits**: Individual characteristics that shape their responses
- **Welcome Messages**: Personalized greetings based on their personality

### Example Personalities:

- **Pandit Rajesh Shastri**: Formal, scholarly, uses Sanskrit terms, traditional approach
- **Sadhvi Priya Devi**: Warm, compassionate, empathetic, nurturing
- **Swami Anand Bharti**: Spiritual, profound, philosophical, mystical
- **Dr. Sunita Acharya**: Professional, knowledgeable, medical astrology focus

## Features

✅ **34 Unique AI Personalities**: Each pandit responds with their unique voice
✅ **Specialization-Based Responses**: AI uses their expertise areas
✅ **Experience-Based Wisdom**: Older pandits speak with more authority
✅ **Gender-Appropriate Responses**: Male and female pandits have distinct styles
✅ **Fallback System**: If API fails, uses rule-based responses

## Troubleshooting

### API Key Not Working
- Verify the API key is correct
- Check if you have API access enabled
- Ensure billing is set up (if required)

### Responses Not Personality-Based
- Check that `panditId` is being passed correctly
- Verify the pandit exists in `AIPandits.allPandits`
- Check console logs for errors

### Slow Responses
- Check your internet connection
- The API has a 30-second timeout
- Consider implementing caching for common queries

## API Limits

- Free tier: 60 requests per minute
- Paid tier: Higher limits available
- Check [Google AI Studio](https://makersuite.google.com) for current limits

## Security Notes

⚠️ **Never commit API keys to version control**
- Add `lib/core/config/gemini_config.dart` to `.gitignore` if storing keys there
- Use environment variables or secure storage for production
- Consider using a backend proxy to protect your API key

## Support

For issues or questions:
1. Check the console logs for error messages
2. Verify API key is valid
3. Test with a simple message first
4. Check network connectivity

